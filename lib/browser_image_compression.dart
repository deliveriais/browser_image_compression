import 'dart:async';
import 'js.dart'
if (dart.library.html) 'package:js/js.dart' as js;
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';


@js.JS()
@js.anonymous
class OptionsJS {
  external factory OptionsJS({
    /** @default Number.POSITIVE_INFINITY */
    double? maxSizeMB,
    /** @default undefined */
    double? maxWidthOrHeight,
    /** @default true */
    bool? useWebWorker,
    /** @default 10 */
    double? maxIteration,
    /** Default to be the exif orientation from the image file */
    double? exifOrientation,
    /** A function takes one progress argument (progress from 0 to 100) */
    Function(double progress)? onProgress,
    /** Default to be the original mime type from the image file */
    String? fileType,
    /** @default 1.0 */
    double? initialQuality,
    /** @default false */
    bool? alwaysKeepResolution,
    /** @default undefined */
    // AbortSignal? signal,
    /** @default false */
    bool? preserveExif,
    /** @default https://cdn.jsdelivr.net/npm/browser-image-compression/dist/browser-image-compression.js */
    String? libURL,
  });
}

class Options {
  late OptionsJS impl;

  Options({
    /** @default Number.POSITIVE_INFINITY */
    double maxSizeMB = 1,
    /** @default undefined */
    double maxWidthOrHeight = 2048,
    /** @default true */
    bool useWebWorker = true,
    /** @default 10 */
    double maxIteration = 10,
    /** Default to be the exif orientation from the image file */
    double? exifOrientation,
    /** A function takes one progress argument (progress from 0 to 100) */
    Function(double progress)? onProgress,
    /** Default to be the original mime type from the image file */
    String? fileType,
    /** @default 1.0 */
    double initialQuality = 1,
    /** @default false */
    bool alwaysKeepResolution = false,
    /** @default undefined */
    // AbortSignal? signal,
    /** @default false */
    bool preserveExif = false,
    /** @default https://cdn.jsdelivr.net/npm/browser-image-compression/dist/browser-image-compression.js */
    String? libURL,
  }) : impl = OptionsJS(
          maxSizeMB: maxSizeMB,
          maxWidthOrHeight: maxWidthOrHeight,
          useWebWorker: useWebWorker,
          maxIteration: maxIteration,
          exifOrientation: exifOrientation,
          onProgress: (onProgress != null) ? js.allowInterop(onProgress) : null,
          fileType: fileType,
          initialQuality: initialQuality,
          alwaysKeepResolution: alwaysKeepResolution,
          preserveExif: preserveExif,
          libURL: libURL,
        );
}

@js.JS("imageCompression")
external Promise imageCompression(html.File file, OptionsJS optionsJS);

class BrowserImageCompression {
  static Future<Uint8List> compressImageByXFile(
      XFile xfile, Options opts) async {
    var completer = Completer<Uint8List>();

    var file = html.File(
      [await xfile.readAsBytes()],
      xfile.name,
      {'type': xfile.mimeType},
    );

    var value =
        await completerForPromise(imageCompression(file, opts.impl)).future;

    var r = html.FileReader();

    r.readAsArrayBuffer(value);

    r.onLoadEnd.listen((data) {
      completer.complete(r.result as Uint8List);
    });

    return completer.future;
  }

  static Future<Uint8List> compressImage(
      String filename, Uint8List data, String mineType, Options opts) async {
    var completer = Completer<Uint8List>();

    var file = html.File(
      [data],
      filename,
      {'type': mineType},
    );

    var value =
        await completerForPromise(imageCompression(file, opts.impl)).future;

    var r = html.FileReader();

    r.readAsArrayBuffer(value);

    r.onLoadEnd.listen((data) {
      completer.complete(r.result as Uint8List);
    });

    return completer.future;
  }
}

@js.JS("Promise")
class Promise {
  external Object then(Function onFulfilled, Function onRejected);
  external static Promise resolve(dynamic value);
}

/// Creates a completer for the given JS promise.
Completer<T> completerForPromise<T>(Promise promise) {
  Completer<T> out = Completer();

  // Create interopts for promise
  promise.then(js.allowInterop((value) {
    out.complete(value);
  }), js.allowInterop(([value]) {
    out.completeError(value, StackTrace.current);
  }));

  return out;
}
