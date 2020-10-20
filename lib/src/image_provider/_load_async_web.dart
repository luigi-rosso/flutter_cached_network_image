import 'dart:async';
import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../../cached_network_image.dart';

Future<ui.Codec> loadAsyncHtmlImage(
  CachedNetworkImageProvider key,
  StreamController<ImageChunkEvent> chunkEvents,
  DecoderCallback decode,
) async {
  final resolved = Uri.base.resolve(key.url);

  return runZonedGuarded<Future<ui.Codec>>(() async {
    return await (ui.webOnlyInstantiateImageCodecFromUrl(
      // ignore: undefined_function
      resolved,
      chunkCallback: (int bytes, int total) {
        chunkEvents.add(
          ImageChunkEvent(
            cumulativeBytesLoaded: bytes,
            expectedTotalBytes: total,
          ),
        );
      },
    ) as Future<ui.Codec>);
  }, (error, __) {
    if (error is ProgressEvent) {
      // Intentionally empty, swallowing ProgressEvent (Flutter Web seems to
      // throw this ProgressEvent when doing certain operations on an HTTP
      // request). See https://github.com/flutter/flutter/issues/60239
    } else {
      throw error;
    }
  });
}
