import 'package:sendme_outlet/src/common/app_functions.dart';
import 'package:sendme_outlet/src/models/address.dart';

class OutletOrderOrUserOrderDetail {
  int? orderId;
  int? orderStatus;
  int? paymentMode;
  int? userId;
  int? hotelId;
  int? deliveryType;

  double? totalBill;
  double? netBill;
  double? itemTotal;
  double? additionalCharges;
  double? cGST;
  double? sGST;
  double? deliveryCharge;

  String? orderOn;
  String? deliveryOn;
  String? deliveredAt;
  String? paymentType;
  String? userName;
  String? mobile;
  String? riderName;
  String? riderNumber;
  String? currency;
  String? slot;
  String? remarks;
  String? adminRemark;
  String? reason;

  List<Map<String, dynamic>>? orderDetail;
  List<Map<String, dynamic>>? requestOrderDetails;
  AddressModel? address;

  OutletOrderOrUserOrderDetail({
    this.orderId,
    this.orderStatus,
    this.paymentMode,
    this.userId,
    this.hotelId,
    this.deliveryType,
    this.totalBill,
    this.netBill,
    this.itemTotal,
    this.additionalCharges,
    this.cGST,
    this.sGST,
    this.deliveryCharge,
    this.orderOn,
    this.deliveryOn,
    this.deliveredAt,
    this.paymentType,
    this.userName,
    this.mobile,
    this.riderName,
    this.riderNumber,
    this.currency,
    this.slot,
    this.remarks,
    this.adminRemark,
    this.reason,
    this.orderDetail,
    this.requestOrderDetails,
    this.address,
  });

  factory OutletOrderOrUserOrderDetail.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>>? orderDetailList;
    if (json['orderDetail'] != null) {
      final list = json['orderDetail'] as List;
      orderDetailList = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    List<Map<String, dynamic>>? requestList;
    if (json['requestOrderDetails'] != null) {
      final list = json['requestOrderDetails'] as List;
      requestList = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    AddressModel? addr;
    if (json['Address'] != null) {
      addr = AddressModel.fromJson(json['Address'] as Map<String, dynamic>);
    }
    return OutletOrderOrUserOrderDetail(
      orderId: funToInt(json['orderId'] ?? json['OrderId']),
      orderStatus: funToInt(json['orderStatus'] ?? json['OrderStatus']),
      paymentMode: funToInt(json['paymentMode'] ?? json['PaymentMode']),
      userId: funToInt(json['userId'] ?? json['UserId']),
      hotelId: funToInt(json['hotelId'] ?? json['HotelId']),
      deliveryType: funToInt(json['deliveryType'] ?? json['DeliveryType']),
      netBill: funToDouble(json['NetBill']) ?? funToDouble(json['netBill']),
      itemTotal: funToDouble(json['itemTotal'] ?? json['ItemTotal']),
      additionalCharges: funToDouble(json['additionalCharges']),
      cGST: funToDouble(json['CGST'] ?? json['cGST']),
      sGST: funToDouble(json['SGST'] ?? json['sGST']),
      deliveryCharge: funToDouble(json['deliveryCharge'] ?? json['DeliveryCharge']),
      orderDetail: orderDetailList,
      requestOrderDetails: requestList,
      address: addr,
      totalBill: funToDouble(json['totalBill'] ?? json['TotalBill']),
      orderOn: funToString(json['orderOn'] ?? json['OrderOn']) ?? '',
      deliveryOn: funToString(json['deliveryOn'] ?? json['DeliveryOn']) ?? '',
      deliveredAt: funToString(json['orderDeliveredDate'] ?? json['OrderDeliveredDate']) ?? '',
      paymentType: funToString(json['paymentType'] ?? json['PaymentType']) ?? '',
      userName: funToString(json['userName'] ?? json['UserName']) ?? '',
      mobile: funToString(json['mobile'] ?? json['Mobile']) ?? funToString(json['ContactNo']) ?? '',
      riderName: funToString(json['riderName']),
      riderNumber: funToString(json['riderNumber']),
      remarks: funToString(json['remarks']),
      adminRemark: funToString(json['adminRemark']),
      reason: funToString(json['reason']),
      currency: funToString(json['currency']) ?? '',
      slot: funToString(json['Slot']) ?? funToString(json['slot']) ?? '',
    );
  }
}
