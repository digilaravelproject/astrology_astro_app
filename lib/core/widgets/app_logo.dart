import 'package:flutter/material.dart';
import '../constants/image_constants.dart';

class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppLogo({
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      ImageConstants.logo,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
