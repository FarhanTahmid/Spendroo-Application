import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/db/database.dart';
import '../../core/entitlements/entitlements.dart';
import '../../core/entitlements/entitlements_controller.dart';
import '../../core/providers.dart';
import '../../core/ui.dart';
import '../../l10n/app_localizations.dart';
import '../plan/upgrade_sheet.dart';
import 'report_custom.dart';
import 'report_repository.dart';

/// Whether the report of a whole business is open to this member: those who
/// see every cashbook. Staff see only the books they were given.
bool canDownloadBusinessReport(Workspace workspace) => const {'owner', 'admin', 'viewer'}.contains(workspace.role);

/// The one place a report is downloaded from, whatever it is about: it says
/// what the report covers, asks for the period and the file type, and hands
/// over the file. [subjectId] and [subjectName] are the account, cashbook or
/// business; the personal report needs neither.
Future<void> showReportSheet(
  BuildContext context, {
  required ReportScope scope,
  required Workspace workspace,
  String? subjectId,
  String subjectName = '',
}) => showAppSheet<void>(
  context,
  title: context.l10n.reportDownload,
  // The sheet scrolls its choices itself, so the Download button stays in reach
  scrolls: false,
  builder: (_) => _ReportSheet(scope: scope, workspace: workspace, subjectId: subjectId, subjectName: subjectName),
);

/// The app-bar button that opens [showReportSheet]. The same icon everywhere.
class ReportButton extends StatelessWidget {
  const ReportButton({super.key, required this.scope, required this.workspace, this.subjectId, this.subjectName = ''});

  final ReportScope scope;
  final Workspace workspace;
  final String? subjectId;
  final String subjectName;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: context.l10n.reportDownload,
    icon: const Icon(Icons.download_rounded),
    onPressed: () =>
        showReportSheet(context, scope: scope, workspace: workspace, subjectId: subjectId, subjectName: subjectName),
  );
}

String _title(AppLocalizations l10n, ReportScope scope) => switch (scope) {
  ReportScope.personal => l10n.reportTitlePersonal,
  ReportScope.account => l10n.reportTitleAccount,
  ReportScope.cashbook => l10n.reportTitleCashbook,
  ReportScope.business => l10n.reportTitleBusiness,
};

String _covers(AppLocalizations l10n, ReportScope scope, String name) => switch (scope) {
  ReportScope.personal => l10n.reportCoversPersonal,
  ReportScope.account => l10n.reportCoversAccount(name),
  ReportScope.cashbook => l10n.reportCoversCashbook(name),
  ReportScope.business => l10n.reportCoversBusiness(name),
};

List<String> _inside(AppLocalizations l10n, ReportScope scope) => switch (scope) {
  ReportScope.personal => [l10n.reportInsidePersonal1, l10n.reportInsidePersonal2, l10n.reportInsidePersonal3],
  ReportScope.account => [l10n.reportInsideAccount1, l10n.reportInsideAccount2, l10n.reportInsideAccount3],
  ReportScope.cashbook => [l10n.reportInsideCashbook1, l10n.reportInsideCashbook2, l10n.reportInsideCashbook3],
  ReportScope.business => [l10n.reportInsideBusiness1, l10n.reportInsideBusiness2, l10n.reportInsideBusiness3],
};

IconData _icon(ReportScope scope) => switch (scope) {
  ReportScope.personal => Icons.person_outline_rounded,
  ReportScope.account => Icons.account_balance_wallet_outlined,
  ReportScope.cashbook => Icons.menu_book_outlined,
  ReportScope.business => Icons.storefront_outlined,
};

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({required this.scope, required this.workspace, this.subjectId, required this.subjectName});

  final ReportScope scope;
  final Workspace workspace;
  final String? subjectId;
  final String subjectName;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  static const _sides = EdgeInsets.symmetric(horizontal: 20);

  ReportPeriod _period = ReportPeriod.thisMonth;
  ReportCustom? _custom;
  ReportFileType _fileType = ReportFileType.pdf;
  bool _busy = false;
  String? _error;
  ReportFile? _file;

  /// Where in the phone's storage the report was put; null when it could not be.
  String? _savedTo;

  /// Whether the plan keeps [feature] from this user. Only the owner's own
  /// plan is known on the phone: in someone else's business the server decides.
  bool _locked(String feature) {
    final plan = ref.read(entitlementsProvider).value;
    if (plan == null || !plan.enforced || widget.workspace.role != 'owner') return false;
    return !plan.can(feature);
  }

  /// Says what the plan lacks on the upgrade sheet. True when the feature is
  /// (or has just become) the user's.
  Future<bool> _unlock(String feature) async {
    if (!_locked(feature)) return true;
    await guarded(context, () => ref.read(planGuardProvider).require(feature, widget.workspace.id));
    return mounted && !_locked(feature);
  }

  Future<void> _pickPeriod(ReportPeriod period) async {
    HapticFeedback.selectionClick();
    if (period != ReportPeriod.custom) return setState(() => _period = period);
    if (!await _unlock(F.reportsCustomRange) || !mounted) return;
    final picked = await showReportCustomSheet(
      context,
      subject: (widget.scope, widget.workspace.id, widget.subjectId),
      initial: _custom,
    );
    if (picked != null && mounted) {
      setState(() {
        _custom = picked;
        _period = ReportPeriod.custom;
      });
    }
  }

  Future<void> _pickFileType(ReportFileType fileType) async {
    HapticFeedback.selectionClick();
    if (fileType == ReportFileType.excel && !await _unlock(F.reportsExcel)) return;
    if (mounted) setState(() => _fileType = fileType);
  }

  (String, String) get _dates => _period.range() ?? (_custom!.from, _custom!.to);

  Future<void> _download() async {
    final l10n = context.l10n;
    final language = context.languageCode;
    setState(() {
      _busy = true;
      _error = null;
    });
    String? error;
    ReportFile? file;
    try {
      // The server builds the report from what it holds: send it what is still on the phone
      if ((ref.read(pendingChangesProvider).value ?? 0) > 0) {
        await ref.read(syncControllerProvider.notifier).syncNow();
      }
      final (from, to) = _dates;
      final custom = _period == ReportPeriod.custom ? _custom : null;
      file = await ref
          .read(reportRepositoryProvider)
          .download(
            ReportRequest(
              scope: widget.scope,
              subjectId: widget.subjectId,
              period: _period,
              from: from,
              to: to,
              types: [...?custom?.types],
              categoryIds: custom?.categoryIds ?? const [],
              uncategorised: custom?.uncategorised ?? false,
              fileType: _fileType,
              language: language == 'bn' ? 'bn' : 'en',
            ),
          );
    } on OfflineException {
      error = l10n.reportOffline;
    } on PlanLimitException catch (refusal) {
      // The phone's copy of the plan was out of date, or the business is on its owner's plan
      if (mounted) await showUpgradeSheet(context, refusal: refusal);
    } on ReportException catch (problem) {
      error = switch (problem.reason) {
        ReportException.tooLarge => l10n.reportTooLarge(problem.limit ?? 0),
        ReportException.throttled => l10n.reportThrottled,
        _ => l10n.reportFailed,
      };
    }
    if (!mounted) return;
    // Into the phone's Downloads folder, where a downloaded file is looked for
    final savedTo = file == null ? null : await ref.read(reportOpenerProvider).saveToDownloads(file);
    if (!mounted) return;
    if (file != null) showEventBurst(context, AppEvent.saved);
    setState(() {
      _busy = false;
      _error = error;
      _file = file;
      _savedTo = savedTo;
    });
  }

  /// "Download/Spendroo/report.pdf" as the Files app words it: "Download › Spendroo".
  String _folderOf(String savedTo) {
    final parts = savedTo.split('/');
    return parts.take(parts.length - 1).join(' › ');
  }

  Future<void> _open(ReportFile file) async {
    final opened = await ref.read(reportOpenerProvider).open(file);
    if (!opened && mounted) setState(() => _error = context.l10n.reportNoApp);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    // A plan bought from the upgrade sheet unlocks the choices at once
    ref.watch(entitlementsProvider);
    final file = _file;
    final (from, to) = _period == ReportPeriod.custom && _custom == null ? (null, null) : _dates;

    final about = Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(color: colors.field, borderRadius: BorderRadius.circular(AppRadius.control)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colors.header,
            child: Icon(_icon(widget.scope), color: colors.onHeader, size: 20),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_title(l10n, widget.scope), style: text.titleMedium),
                const SizedBox(height: 2),
                Text(_covers(l10n, widget.scope, widget.subjectName), style: text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );

    if (file != null) {
      return SingleChildScrollView(
        padding: _sides.copyWith(bottom: AppSpace.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            about,
            const SizedBox(height: AppSpace.lg),
            Row(
              children: [
                Icon(Icons.check_circle_rounded, color: colors.moneyIn),
                const SizedBox(width: AppSpace.sm),
                Expanded(child: Text(l10n.reportReady, style: text.titleMedium)),
              ],
            ),
            const SizedBox(height: AppSpace.sm),
            Text(file.name, style: text.bodyMedium),
            const SizedBox(height: AppSpace.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _savedTo == null ? Icons.info_outline_rounded : Icons.folder_outlined,
                  size: 18,
                  color: colors.muted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _savedTo == null ? l10n.reportNotSaved : l10n.reportSavedTo(_folderOf(_savedTo!)),
                    style: text.bodyMedium?.copyWith(fontWeight: _savedTo == null ? null : FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (file.reference.isNotEmpty)
              Text(l10n.reportReference(file.reference), style: text.bodySmall?.copyWith(color: colors.muted)),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpace.sm),
                child: Text(_error!, style: text.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error)),
              ),
            const SizedBox(height: AppSpace.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.ios_share_rounded),
                    label: Text(l10n.reportShare),
                    onPressed: () => ref.read(reportOpenerProvider).share(file),
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: Text(l10n.reportOpen),
                    onPressed: () => _open(file),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => setState(() {
                _file = null;
                _error = null;
              }),
              child: Text(l10n.reportAnother),
            ),
          ],
        ),
      );
    }

    final periods = {
      ReportPeriod.thisMonth: l10n.thisMonth,
      ReportPeriod.lastMonth: l10n.periodLastMonth,
      ReportPeriod.last3Months: l10n.periodLast3Months,
      ReportPeriod.thisYear: l10n.periodThisYear,
      ReportPeriod.custom: l10n.periodCustom,
    };

    final choices = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        about,
        const SizedBox(height: AppSpace.md),
        Text(l10n.reportInside, style: text.titleSmall),
        const SizedBox(height: 4),
        for (final line in _inside(l10n, widget.scope))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 8),
                  child: Icon(Icons.check_rounded, size: 16, color: colors.moneyIn),
                ),
                Expanded(child: Text(line, style: text.bodyMedium)),
              ],
            ),
          ),
        const SizedBox(height: AppSpace.lg),
        Text(l10n.reportPeriod, style: text.titleSmall),
        const SizedBox(height: AppSpace.sm),
        Wrap(
          spacing: AppSpace.sm,
          runSpacing: AppSpace.sm,
          children: [
            for (final MapEntry(key: period, value: label) in periods.entries)
              ChoiceChip(
                key: ValueKey('report-period-${period.code}'),
                label: Text(label),
                avatar: period == ReportPeriod.custom
                    ? Icon(
                        _locked(F.reportsCustomRange) ? Icons.lock_outline_rounded : Icons.date_range_rounded,
                        size: 16,
                      )
                    : null,
                showCheckmark: false,
                selected: _period == period,
                onSelected: _busy ? null : (_) => _pickPeriod(period),
              ),
          ],
        ),
        if (from != null && to != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.sm),
            // The exact days, so "3 months" is never a guess
            child: Text(
              '${formatDate(context, from)} – ${formatDate(context, to)}',
              style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        // What a custom report is narrowed to, in words, before it is downloaded
        if (_period == ReportPeriod.custom && _custom != null) ...[
          if (_custom!.types.isNotEmpty)
            Text(
              '${l10n.reportCustomTypes}: ${[for (final type in reportTypes(widget.scope))
                if (_custom!.types.contains(type)) reportTypeLabel(l10n, type)].join(', ')}',
              style: text.bodyMedium,
            ),
          if (_custom!.hasCategories)
            Text(
              '${l10n.categories}: ${[for (final category in _custom!.categories) category.label, if (_custom!.uncategorised) l10n.uncategorised].join(', ')}',
              style: text.bodyMedium,
            ),
        ],
        const SizedBox(height: AppSpace.lg),
        Text(l10n.reportFileType, style: text.titleSmall),
        const SizedBox(height: AppSpace.sm),
        _FileTypeTile(
          key: const ValueKey('report-file-pdf'),
          icon: Icons.picture_as_pdf_outlined,
          name: 'PDF',
          hint: l10n.reportPdfHint,
          tag: l10n.reportFree,
          selected: _fileType == ReportFileType.pdf,
          onTap: _busy ? null : () => _pickFileType(ReportFileType.pdf),
        ),
        const SizedBox(height: AppSpace.sm),
        _FileTypeTile(
          key: const ValueKey('report-file-xlsx'),
          icon: Icons.table_chart_outlined,
          name: 'Excel',
          hint: l10n.reportExcelHint,
          tag: _locked(F.reportsExcel) ? l10n.reportPaid : null,
          locked: _locked(F.reportsExcel),
          selected: _fileType == ReportFileType.excel,
          onTap: _busy ? null : () => _pickFileType(ReportFileType.excel),
        ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(padding: _sides, child: choices),
        ),
        // Below the scrolling choices, where a thumb finds it on any phone
        Padding(
          padding: _sides.copyWith(top: AppSpace.md, bottom: AppSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _error ?? l10n.reportHint,
                style: _error == null
                    ? text.bodySmall?.copyWith(color: colors.muted)
                    : text.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: AppSpace.md),
              BusyButton(
                icon: Icons.download_rounded,
                label: _fileType == ReportFileType.pdf ? l10n.reportDownloadPdf : l10n.reportDownloadExcel,
                busy: _busy,
                onPressed: _download,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One of the two file types: what it is, what it is good for, and whether the plan has it.
class _FileTypeTile extends StatelessWidget {
  const _FileTypeTile({
    super.key,
    required this.icon,
    required this.name,
    required this.hint,
    required this.selected,
    required this.onTap,
    this.tag,
    this.locked = false,
  });

  final IconData icon;
  final String name;
  final String hint;

  /// "Free" or "Paid plan", at the end of the row.
  final String? tag;
  final bool locked;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.control),
        onTap: onTap,
        child: AnimatedContainer(
          duration: context.motion(AppMotion.standard),
          padding: const EdgeInsets.all(AppSpace.md),
          decoration: BoxDecoration(
            color: selected ? scheme.primary.withValues(alpha: 0.08) : null,
            borderRadius: BorderRadius.circular(AppRadius.control),
            border: Border.all(color: selected ? scheme.primary : colors.hairline, width: selected ? 1.6 : 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? scheme.primary : colors.muted),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: text.titleSmall),
                    Text(hint, style: text.bodySmall?.copyWith(color: colors.muted)),
                  ],
                ),
              ),
              if (tag != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (locked ? colors.gold : colors.moneyIn).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (locked) ...[const Icon(Icons.lock_outline_rounded, size: 13), const SizedBox(width: 3)],
                      Text(tag!, style: text.labelSmall),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
