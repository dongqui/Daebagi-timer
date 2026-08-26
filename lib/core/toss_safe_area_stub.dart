import 'package:flutter/widgets.dart';

/// 네이티브 빌드는 토스 웹뷰 안에서 돌지 않는다.
/// OS가 알려주는 `MediaQuery.padding`이 이미 정확하다.
EdgeInsets? tossSafeAreaInsets() => null;
