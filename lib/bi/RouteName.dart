// class RouteName {
//   static String register = "/register";
//   static String login = "/login";
//   //need_id
//   static String createDZ = "/need_id/create_dz_page/create_dz";
//   static String sendReview = "/need_id/dz_page/send_review";
//   //no_id
//   static String getDZ = "/no_id/home_page/get_dz";
//   static String enterDZ = "/no_id/dz_page/enter_dz";
// }
class RouteName {
  static MainRoutes mainRoutes = MainRoutes();
  static NeedIdRoutes needIdRoutes = NeedIdRoutes();
  static NoIdRoutes noIdRoutes = NoIdRoutes();
}

///
///
///
///
///
class MainRoutes {
  String login = "/login";
  String needId = "/need_id";
  String register = "/register";
}

///
///
///
///
///
class NeedIdRoutes {
  NeedIdRoutesCreateDzPage createDzPage = NeedIdRoutesCreateDzPage();
  NeedIdRoutesDzPage dzPage = NeedIdRoutesDzPage();
}

class NeedIdRoutesCreateDzPage {
  String createDz = "/need_id/create_dz_page/create_dz";
}

class NeedIdRoutesDzPage {
  String sendReview = "/need_id/dz_page/send_review";
}

///
///
///
///
///
class NoIdRoutes {
  NoIdRoutesDzPage dzPage = NoIdRoutesDzPage();
  NoIdRouteHomePage homePage = NoIdRouteHomePage();
}

class NoIdRoutesDzPage {
  String enterDz = "/no_id/dz_page/enter_dz";
  String getReview1 = "/no_id/dz_page/get_review1";
  String getStar = "/no_id/dz_page/get_star";
  String getLike = "/no_id/dz_page/get_like";
}

class NoIdRouteHomePage {
  String getDz = "/no_id/home_page/get_dz";
}
