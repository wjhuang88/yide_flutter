
Type lastPageType;

double menuAnimationOffset = 0.0;
bool isScreenTransitionVertical = false;

List<String> routeNames = List();
String get lastRouteName {
  if (routeNames.length > 1) {
    return routeNames[routeNames.length - 2];
  }
  return '';
}
