import 'dart:typed_data';

import 'package:flutter/material.dart';

/// TomzaImage: Widget optimizado para mostrar PNG/JPG desde diferentes fuentes
/// - networkUrl: carga desde la red con placeholder y error widget
/// - assetName: carga desde assets cuando se pasa
/// - bytes: carga desde memoria (Uint8List)
/// Prioriza `bytes` > `assetName` > `networkUrl`.
class TomzaImage extends StatelessWidget {
  const TomzaImage.network(
    this.networkUrl, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius = 8.0,
    this.headers,
    this.cacheWidth,
    this.cacheHeight,
  }) : bytes = null,
       assetName = null;

  const TomzaImage.asset(
    this.assetName, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius = 8.0,
    this.cacheWidth,
    this.cacheHeight,
  }) : networkUrl = null,
       bytes = null,
       headers = null;

  const TomzaImage.memory(
    this.bytes, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius = 8.0,
    this.cacheWidth,
    this.cacheHeight,
  }) : networkUrl = null,
       assetName = null,
       headers = null;

  final String? networkUrl;
  final String? assetName;
  final Uint8List? bytes;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double borderRadius;

  /// Optional headers for network requests if needed
  final Map<String, String>? headers;

  /// Optional cache resize hints for Image.network / Image.memory
  final int? cacheWidth;
  final int? cacheHeight;

  Widget _defaultPlaceholder(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    child: Center(
      child: Icon(
        Icons.image,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );

  Widget _defaultError(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    child: Center(
      child: Icon(
        Icons.broken_image,
        color: Theme.of(context).colorScheme.onErrorContainer,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final Widget ph = placeholder ?? _defaultPlaceholder(context);
    final Widget err = errorWidget ?? _defaultError(context);

    if (bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.memory(
          bytes!,
          width: width,
          height: height,
          fit: fit,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          errorBuilder: (context, error, stackTrace) => err,
        ),
      );
    }

    if (assetName != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          assetName!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => err,
        ),
      );
    }

    if (networkUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          networkUrl!,
          width: width,
          height: height,
          fit: fit,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          frameBuilder:
              (
                BuildContext context,
                Widget child,
                int? frame,
                bool wasSynchronouslyLoaded,
              ) {
                if (wasSynchronouslyLoaded) {
                  return child;
                }
                if (frame == null) {
                  return ph;
                }
                return child;
              },
          errorBuilder: (context, error, stackTrace) => err,
        ),
      );
    }

    return _defaultPlaceholder(context);
  }
}
