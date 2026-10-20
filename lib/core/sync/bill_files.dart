import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Where bill files sit on the phone: the ones waiting to be sent, and the
/// ones opened before, kept so they open again offline. Each is named after
/// its bill's id, so finding one needs no table.
class BillFiles {
  BillFiles([Future<Directory> Function()? root]) : _root = root ?? _appFolder;

  final Future<Directory> Function() _root;

  static Future<Directory> _appFolder() async =>
      Directory(p.join((await getApplicationSupportDirectory()).path, 'bills'));

  static String extensionFor(String contentType) => switch (contentType) {
        'application/pdf' => 'pdf',
        'image/png' => 'png',
        _ => 'jpg',
      };

  Future<Directory> _folder(String name) async {
    final folder = Directory(p.join((await _root()).path, name));
    await folder.create(recursive: true);
    return folder;
  }

  /// Where a file waiting to be sent is kept.
  Future<File> pending(String id, String contentType) async =>
      File(p.join((await _folder('pending')).path, '$id.${extensionFor(contentType)}'));

  /// Where an opened (or just sent) bill is kept.
  Future<File> cached(String id, String contentType) async =>
      File(p.join((await _folder('cache')).path, '$id.${extensionFor(contentType)}'));

  /// The bill's file on this phone, sent or not, if there is one.
  Future<File?> find(String id, String contentType) async {
    for (final file in [await cached(id, contentType), await pending(id, contentType)]) {
      if (await file.exists()) return file;
    }
    return null;
  }

  /// A file that was waiting is on the server now: keep it as the cached copy.
  Future<void> adopt(File waiting, String id, String contentType) async {
    if (!await waiting.exists()) return;
    final target = await cached(id, contentType);
    try {
      await waiting.rename(target.path);
    } on FileSystemException {
      await waiting.copy(target.path);
      await waiting.delete();
    }
  }

  /// Removes every file of these bills.
  Future<void> drop(Iterable<String> ids) async {
    final names = ids.toSet();
    if (names.isEmpty) return;
    await _each((file) async {
      if (names.contains(p.basenameWithoutExtension(file.path))) await file.delete();
    });
  }

  /// Removes the files of every bill not in [ids]: removed, or purged with a
  /// book. A file younger than [grace] stays, as its bill may be being saved
  /// right now.
  Future<void> keepOnly(Set<String> ids, {Duration grace = const Duration(minutes: 10)}) {
    final cutoff = DateTime.now().subtract(grace);
    return _each((file) async {
      if (ids.contains(p.basenameWithoutExtension(file.path))) return;
      if ((await file.lastModified()).isAfter(cutoff)) return;
      await file.delete();
    });
  }

  /// Signing out: nothing of the previous user stays. Never stands in the way
  /// of signing out; what cannot go now goes with the next keepOnly.
  Future<void> clear() async {
    try {
      final root = await _root();
      if (await root.exists()) await root.delete(recursive: true);
    } catch (_) {
      // No folder to reach (tests have no file system plugin), or a file still open
    }
  }

  Future<void> _each(Future<void> Function(File file) action) async {
    final Directory root;
    try {
      root = await _root();
    } catch (_) {
      return; // no folder to reach (tests have no file system plugin): nothing kept there either
    }
    if (!await root.exists()) return;
    await for (final item in root.list(recursive: true)) {
      if (item is File) {
        try {
          await action(item);
        } on FileSystemException {
          // Open elsewhere or gone already: the next pass tries again
        }
      }
    }
  }
}
