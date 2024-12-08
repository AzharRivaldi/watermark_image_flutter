import 'package:flutter/material.dart';
import 'package:watermark_images_flutter/tools/widgetstoimagecontroller.dart';

class WidgetsToImage extends StatelessWidget {
  final Widget? child;
  final WidgetsToImageController controller;

  const WidgetsToImage({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: controller.containerKey,
      child: child,
    );
  }

}