/// 네이티브 빌드용 stub. 걷어낼 부트 화면이 없다.
void hideBootScreen() {}

/// 네이티브에는 부트 화면이 없으므로 인트로가 곧 시작점이다.
Duration bootElapsed() => Duration.zero;
