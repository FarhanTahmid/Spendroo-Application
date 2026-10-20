import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

/// A file chosen as a bill, not yet attached to anything.
class PickedBill {
  const PickedBill({required this.path, required this.name, required this.contentType, required this.sizeBytes});

  final String path;

  /// What the person called it, shown in the viewer.
  final String name;

  /// What the first bytes prove it to be (see [sniffBill]); the server checks again.
  final String contentType;
  final int sizeBytes;

  bool get isPdf => contentType == pdfType;
}

const jpegType = 'image/jpeg';
const pngType = 'image/png';
const pdfType = 'application/pdf';

/// The file's type by its first bytes, as the server judges it; null for anything else.
String? sniffBill(List<int> head) {
  bool starts(List<int> magic) =>
      head.length >= magic.length && [for (var i = 0; i < magic.length; i++) head[i] == magic[i]].every((same) => same);
  if (starts(const [0xFF, 0xD8, 0xFF])) return jpegType;
  if (starts(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) return pngType;
  if (starts(const [0x25, 0x50, 0x44, 0x46, 0x2D])) return pdfType; // %PDF-
  return null;
}

/// The file was not a photo or a PDF.
class NotABillException implements Exception {
  const NotABillException();
}

/// Opens the camera, the gallery or the file chooser. Tests override it.
class BillPicker {
  /// A camera photo of a receipt is plenty sharp at this size, and small enough for any plan.
  static const _longestEdge = 2048.0;
  static const _quality = 82;

  Future<PickedBill?> photo({required bool camera}) async {
    final picked = await ImagePicker().pickImage(
      source: camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: _longestEdge,
      maxHeight: _longestEdge,
      imageQuality: _quality,
      requestFullMetadata: false,
    );
    // The picker names its copy scaled_40.jpg and the like: name it after the moment instead
    return picked == null ? null : describe(picked.path, 'Photo ${DateFormat('d MMM yyyy, HH.mm').format(DateTime.now())}.jpg');
  }

  Future<PickedBill?> pdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: false,
    );
    final file = result?.files.singleOrNull;
    if (file?.path == null) return null;
    return describe(file!.path!, file.name);
  }

  /// Reads what the file is. Throws NotABillException for anything but a JPEG, PNG or PDF.
  static Future<PickedBill> describe(String path, String name) async {
    final file = File(path);
    final handle = await file.open();
    final List<int> head;
    try {
      head = await handle.read(8);
    } finally {
      await handle.close();
    }
    final type = sniffBill(head);
    if (type == null) throw const NotABillException();
    return PickedBill(
      path: path,
      name: name.isEmpty ? p.basename(path) : name,
      contentType: type,
      sizeBytes: await file.length(),
    );
  }
}

final billPickerProvider = Provider<BillPicker>((ref) => BillPicker());
