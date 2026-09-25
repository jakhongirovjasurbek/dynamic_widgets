import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomImage extends StatelessWidget {
  const CustomImage({
    required this.source,
    this.height,
    this.width,
    this.fit,
    this.color,
    this.blendMode,
    this.errorWidget,
    this.package,
    super.key,
  });

  final String source;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Color? color;
  final BlendMode? blendMode;
  final Widget? errorWidget;
  final String? package;

  List<String> get _imageExtensions => ['png', 'jpg', 'jpeg', 'gif', 'webp'];

  String get _vectorImageExtension => 'svg';

  static final RegExp _dataUri = RegExp(
    r'^data:image\/(bmp|gif|ico|jpg|jpeg|png|svg\+xml|webp|x-icon);base64,([A-Za-z0-9+/]+={0,2})$',
  );

  RegExpMatch? get _dataUriMatch => _dataUri.firstMatch(source);

  /// File extension, or the mime subtype for a base64 data URI
  /// (`data:image/svg+xml;base64,...` resolves to `svg`).
  String get _extension {
    final match = _dataUriMatch;

    if (match != null) {
      final mime = match.group(1)!.toLowerCase();
      return mime == 'svg+xml' ? 'svg' : mime;
    }

    return source.split('.').last.toLowerCase();
  }

  /// Raw base64 payload of a data URI (prefix stripped), or empty.
  String get _base64Payload => _dataUriMatch?.group(2) ?? '';

  ImageTypeEnum get _imageType {
    if (_dataUriMatch != null) {
      return ImageTypeEnum.memory;
    } else if (source.startsWith('http')) {
      return ImageTypeEnum.network;
    } else if (source.startsWith('assets')) {
      return ImageTypeEnum.asset;
    } else {
      return ImageTypeEnum.file;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imageExtensions.contains(_extension)) {
      return switch (_imageType) {
        ImageTypeEnum.network => CachedNetworkImage(
          imageUrl: source,
          height: height,
          width: width,
          fit: fit,
          color: color,
          colorBlendMode: blendMode,
          errorWidget: errorWidget != null
              ? (context, url, error) => errorWidget ?? const SizedBox.shrink()
              : null,
        ),
        ImageTypeEnum.asset => Image.asset(
          source,
          height: height,
          width: width,
          fit: fit,
          colorBlendMode: blendMode,
          color: color,
          errorBuilder: errorWidget != null
              ? (context, error, stacktrace) => errorWidget ?? const SizedBox.shrink()
              : null,
          package: package,
        ),
        ImageTypeEnum.file => Image.file(
          File(source),
          height: height,
          width: width,
          fit: fit,
          color: color,
          colorBlendMode: blendMode,
          errorBuilder: errorWidget != null
              ? (context, error, stacktrace) => errorWidget ?? const SizedBox.shrink()
              : null,
        ),
        ImageTypeEnum.memory => Image.memory(
          base64Decode(_base64Payload),
          height: height,
          width: width,
          fit: fit,
          color: color,
          colorBlendMode: blendMode,
          errorBuilder: errorWidget != null
              ? (context, error, stacktrace) => errorWidget ?? const SizedBox.shrink()
              : null,
        ),
      };
    } else if (_extension == _vectorImageExtension) {
      final colorFilter = color != null
          ? ColorFilter.mode(color!, blendMode ?? BlendMode.srcIn)
          : null;

      return switch (_imageType) {
        ImageTypeEnum.network => SvgPicture.network(
          source,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
          colorFilter: colorFilter,
          errorBuilder: errorWidget != null
              ? (context, error, stacktrace) => errorWidget ?? const SizedBox.shrink()
              : null,
        ),
        ImageTypeEnum.asset => SvgPicture.asset(
          source,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
          colorFilter: colorFilter,
          errorBuilder: errorWidget != null
              ? (context, error, stacktrace) => errorWidget ?? const SizedBox.shrink()
              : null,
          package: package,
        ),
        ImageTypeEnum.file => const SizedBox.shrink(),
        ImageTypeEnum.memory => SvgPicture.memory(
          base64Decode(_base64Payload),
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
          colorFilter: colorFilter,
          errorBuilder: errorWidget != null
              ? (context, error, stacktrace) => errorWidget ?? const SizedBox.shrink()
              : null,
        ),
      };
    } else {
      return errorWidget != null
          ? SizedBox(height: height, width: width, child: errorWidget)
          : const SizedBox.shrink();
    }
  }
}

enum ImageTypeEnum { network, asset, file, memory }
