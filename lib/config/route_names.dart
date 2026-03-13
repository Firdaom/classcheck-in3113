/// Route names for the application
enum RouteNames {
  login('/login'),
  home('/home'),
  history('/history'),
  profile('/profile'),
  sessionForm('/session-form');

  final String path;

  const RouteNames(this.path);
}
