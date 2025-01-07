// ignore_for_file: camel_case_types

import 'package:flutter/widgets.dart';

class sized{
  static SizedBox h(double height) {
    return SizedBox(height: height);
  }

  static SizedBox w(double width) {
    return SizedBox(width: width);
  }

  static SizedBox hw(double height, double width) {
    return SizedBox(height: height, width: width);
  }
    static SizedBox  s16=sized.h(16);
     static SizedBox  s10=sized.h(10);
  static SizedBox  w10=sized.w(80);
     static SizedBox  s8=sized.h(8);
  static SizedBox  s20=sized.h(20);
    static SizedBox  s80=sized.h(80);
        static SizedBox  s40=sized.h(40);
           static SizedBox  s100=sized.h(100);
            static SizedBox  s160=sized.h(160);
}
