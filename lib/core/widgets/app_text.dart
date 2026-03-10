import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool isHtml;
  final double? fontSize;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final Color? color;
  final double? letterSpacing;
  final double? height;
  final TextDecoration? decoration;

  const AppText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isHtml = false,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.color,
    this.letterSpacing,
    this.height,
    this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If a full style is provided, we merge it with Poppins. 
    // Otherwise, we use the individual parameters.
    final baseStyle = style ?? TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );

    return Text(
      text.tr, // .tr is idempotent if already translated
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      style: baseStyle,
    );
  }
}
