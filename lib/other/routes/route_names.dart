// 협업 및 유지보수를 고려해 go_router를 사용하여 화면 전환 구조를 명확하게 분리하였습니다.
// 추후 페이지 확장과 웹 대응을 염두에 두어, 라우팅 설정을 별도 모듈로 관리하도록 설계했습니다.

abstract class RouteNames {
  static const dashboard = 'dashboard';
  static const settings = 'settings';
  static const authSelection = 'authSelection';
  static const signup = 'signup';
  static const signin = 'signin';
  static const resetPassword = 'resetPassword';
  static const splash = 'splash';
  static const home = 'home';
  static const notificationSetting = 'notificationSetting';
}
