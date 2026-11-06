import 'package:flutter/material.dart';

class UiHelper {
  static Widget customImage({required String img}) {
    return Image.asset("assets/images/$img");
  }

  static Widget customText({
    required String text,
    required Color color,
    required FontWeight fontweight,
    String? fontfamily,
    required double fontsize,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontsize,
        fontFamily: fontfamily ?? "Regular",
        fontWeight: fontweight,
        color: color,
      ),
    );
  }
}
