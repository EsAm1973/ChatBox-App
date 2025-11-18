import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget buildAvatar(
  BuildContext context,
  String imageUrl,
  double width,
  double height,
  double placeholderRadius,
  double errorRadius,
  BoxFit? fitImage,
) {
  return CachedNetworkImage(
    imageUrl: imageUrl,
    fadeOutDuration: const Duration(milliseconds: 300),
    imageBuilder:
        (context, imageProvider) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: fitImage),
          ),
        ),
    placeholder:
        (context, url) => CircleAvatar(
          radius: placeholderRadius,
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          child: const CircularProgressIndicator(),
        ),
    errorWidget:
        (context, url, error) =>
            CircleAvatar(radius: errorRadius, child: const Icon(Icons.error)),
  );
}
