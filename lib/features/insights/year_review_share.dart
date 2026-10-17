import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// The picture inside the [RepaintBoundary] under [key], as PNG bytes; null
/// when it is not on screen.
Future<Uint8List?> captureBoundary(GlobalKey key, {double pixelRatio = 3}) async {
  final boundary = key.currentContext?.findRenderObject();
  if (boundary is! RenderRepaintBoundary) return null;
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}

/// Hands the year's card to whatever the user shares with.
class YearReviewSharer {
  YearReviewSharer({Future<Directory> Function()? folder}) : _folder = folder ?? getTemporaryDirectory;

  final Future<Directory> Function() _folder;

  Future<void> share(Uint8List png, {required int year, required String text}) async {
    final file = File(p.join((await _folder()).path, 'spendroo-$year-in-review.png'));
    await file.writeAsBytes(png, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: text,
      ),
    );
  }
}

final yearReviewSharerProvider = Provider<YearReviewSharer>((ref) => YearReviewSharer());
