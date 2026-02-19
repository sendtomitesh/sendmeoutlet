import 'package:sendme_outlet/src/controllers/theme_ui.dart';

class ApiPath {
  static final String slsServerPath = 'https://sls.sendme.today/';

  /// Common APIs - Auth
  static final String saveOTP = slsServerPath + 'SaveOTP?';
  static final String sendOTP = slsServerPath + 'SendOTP?';
  static final String verifyOTP = slsServerPath + 'verifyOTP?';
  static final String updateUserToken = slsServerPath + 'UpdateUserToken?';

  /// Outlet - switch to outlet and get outlet data
  static final String switchUser = slsServerPath + 'SwitchUser?';

  /// Outlet APIs - Phase 2b
  static final String updateOutletStatus = slsServerPath + 'UpdateOutletStatus?';
  static final String getOutletDashBoardData = slsServerPath + 'GetOutletDashboardData?';
  static final String getOrderList = slsServerPath + 'GetOrderList';
  static final String getHotelDetail = slsServerPath + 'GetHotelDetail?';
  static final String getUserWPOpTin = slsServerPath + 'GetUserWPOptin?';
  static final String orderStatusUpdates = slsServerPath + 'OrderStatusUpdates?';
  static final String getHotelsOrderDetail = slsServerPath + 'GetHotelsOrderDetail?';
  static final String getProductSummaryReport = slsServerPath + 'GetProductSummaryReport?';

  /// Phase 4: Products/Catalogue
  static final String manageCategory = slsServerPath + 'ManageCategory';
  static final String manageSubCategory = slsServerPath + 'ManageSubCategory';
  static final String manageMenuItem = slsServerPath + 'ManageMenuItem';
  static final String getOutletWiseProductCategories = slsServerPath + 'GetOutletWiseProductCategories';
  static final String getOutletSubCategories = slsServerPath + 'GetOutletSubCategory';
  static final String getCategoriesWiseOutletProducts = slsServerPath + 'GetCategoryWiseOutletProducts';
  static final String getProductsByOutletId = slsServerPath + 'GetProductsByOutletId?';
  static final String updateOutletCategoryStatus = slsServerPath + 'UpdateOutletCategoryStatus?';
  static final String uploadToS3 = slsServerPath + 'UploadToS3';
  static final String getAllUnits = slsServerPath + 'GetAllUnits?';
  static final String searchSubItems = slsServerPath + 'SearchSubItems?';

  /// Phase 5: Manage tab
  static final String getStoreMenuTab = slsServerPath + 'GetStoreMenuTab?';

  /// Phase 6: Add Order
  static final String addOrder = slsServerPath + 'AddOrder';
  static final String checkoutOrder = slsServerPath + 'CheckoutOrder';
  static final String getUsersByOutletId = slsServerPath + 'GetUsersByOutletId?';
  static final String getUserFromMobileNumber = slsServerPath + 'GetUserFromMobileNumber?';
  static final String getAddressListByUserId = slsServerPath + 'GetAddressListByUserId?';

  /// Phase 6: WebStore Link
  static final String getOutletWebStoreLink = slsServerPath + 'GetOutletWebStoreLink?';
  static final String generateOutletWebStoreLink = slsServerPath + 'GenerateOutletWebStoreLink?';
}
