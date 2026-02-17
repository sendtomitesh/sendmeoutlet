import 'package:sendme_outlet/src/common/app_functions.dart';

class OrderSummary {
  int? outletId;
  String? outlet;
  List<OrderSummaryProduct>? products;

  OrderSummary({this.outletId, this.outlet, this.products});

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    List<OrderSummaryProduct>? productsList;
    if (json['Products'] != null) {
      final list = json['Products'] as List;
      productsList = list
          .map((v) => OrderSummaryProduct.fromJson(v as Map<String, dynamic>))
          .toList();
    }
    return OrderSummary(
      outletId: funToInt(json['OutletId']),
      outlet: funToString(json['Outlet']),
      products: productsList,
    );
  }
}

class OrderSummaryProduct {
  String? product;
  String? subProduct;
  int? qtySales;
  double? weight;
  String? unit;
  double? totalWeight;
  int? totalOrders;

  OrderSummaryProduct({
    this.product,
    this.subProduct,
    this.qtySales,
    this.weight,
    this.unit,
    this.totalWeight,
    this.totalOrders,
  });

  factory OrderSummaryProduct.fromJson(Map<String, dynamic> json) {
    return OrderSummaryProduct(
      product: funToString(json['product']),
      subProduct: funToString(json['subProduct']) == '' ? null : funToString(json['subProduct']),
      qtySales: funToInt(json['qtySales']),
      weight: funToDouble(json['weight']) ?? 0,
      unit: funToString(json['unit']),
      totalWeight: funToDouble(json['totalWeight']) ?? 0,
      totalOrders: funToInt(json['totalOrders']),
    );
  }
}
