class RiderOrder {
  final String id;
  final String? parentOrderId;
  final String? deliveryType;
  final String? paymentMethod;
  final String? subtotal;
  final String? deliveryFee;
  final String? total;
  final String? couponCode;
  final String? discount;
  final DateTime? orderDate;
  final String? status;
  final String? transactionId;
  final String? trackingNumber;
  final DateTime? estimatedDelivery;
  final RiderOrderMetadata? metadata;
  final DateTime? prepareTime;
  final String? reason;
  final double? pickupDistanceKm;
  final DateTime? pickupTime;
  final int? etaMinutes;
  final String? baseRate;
  final String? distanceBonus;
  final DateTime? offeredAt;
  final DateTime? expiresAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final bool? isOnTime;
  final bool isCombined;
  final dynamic combinedPickups;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? paymentStatus;
  final String? cfOrderId;
  final String? paymentSessionId;

  const RiderOrder({
    required this.id,
    required this.isCombined,
    this.parentOrderId,
    this.deliveryType,
    this.paymentMethod,
    this.subtotal,
    this.deliveryFee,
    this.total,
    this.couponCode,
    this.discount,
    this.orderDate,
    this.status,
    this.transactionId,
    this.trackingNumber,
    this.estimatedDelivery,
    this.metadata,
    this.prepareTime,
    this.reason,
    this.pickupDistanceKm,
    this.pickupTime,
    this.etaMinutes,
    this.baseRate,
    this.distanceBonus,
    this.offeredAt,
    this.expiresAt,
    this.acceptedAt,
    this.completedAt,
    this.isOnTime,
    this.combinedPickups,
    this.createdAt,
    this.updatedAt,
    this.paymentStatus,
    this.cfOrderId,
    this.paymentSessionId,
  });

  factory RiderOrder.fromJson(Map<String, dynamic> json) {
    return RiderOrder(
      id: _asString(json['id']) ?? '',
      parentOrderId: _asString(json['parent_order_id']),
      deliveryType: _asString(json['delivery_type']),
      paymentMethod: _asString(json['payment_method']),
      subtotal: _asString(json['subtotal']),
      deliveryFee: _asString(json['delivery_fee']),
      total: _asString(json['total']),
      couponCode: _asString(json['coupon_code']),
      discount: _asString(json['discount']),
      orderDate: _asDateTime(json['order_date']),
      status: _asString(json['status']),
      transactionId: _asString(json['transaction_id']),
      trackingNumber: _asString(json['tracking_number']),
      estimatedDelivery: _asDateTime(json['estimated_delivery']),
      metadata: RiderOrderMetadata.fromJsonNullable(
        json['metadata'] as Map<String, dynamic>?,
      ),
      prepareTime: _asDateTime(json['prepare_time']),
      reason: _asString(json['reason']),
      pickupDistanceKm: _asDouble(json['pickup_distance_km']),
      pickupTime: _asDateTime(json['pickup_time']),
      etaMinutes: _asInt(json['eta_minutes']),
      baseRate: _asString(json['base_rate']),
      distanceBonus: _asString(json['distance_bonus']),
      offeredAt: _asDateTime(json['offered_at']),
      expiresAt: _asDateTime(json['expires_at']),
      acceptedAt: _asDateTime(json['accepted_at']),
      completedAt: _asDateTime(json['completed_at']),
      isOnTime: _asBool(json['is_on_time']),
      isCombined: _asBool(json['is_combined']) ?? false,
      combinedPickups: json['combined_pickups'],
      createdAt: _asDateTime(json['created_at']),
      updatedAt: _asDateTime(json['updated_at']),
      paymentStatus: _asString(json['payment_status']),
      cfOrderId: _asString(json['cf_order_id']),
      paymentSessionId: _asString(json['payment_session_id']),
    );
  }

  static String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static bool? _asBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value.toString().trim().toLowerCase();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
    return null;
  }

  static DateTime? _asDateTime(dynamic value) {
    final raw = _asString(value);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}

class RiderOrderMetadata {
  final VendorInfo? vendorInfo;
  final OrderPaymentMethod? paymentMethod;
  final DeliveryOption? deliveryOption;
  final ShippingAddress? shippingAddress;

  const RiderOrderMetadata({
    this.vendorInfo,
    this.paymentMethod,
    this.deliveryOption,
    this.shippingAddress,
  });

  factory RiderOrderMetadata.fromJson(Map<String, dynamic> json) {
    return RiderOrderMetadata(
      vendorInfo: VendorInfo.fromJsonNullable(
        json['vendor_info'] as Map<String, dynamic>?,
      ),
      paymentMethod: OrderPaymentMethod.fromJsonNullable(
        json['payment_method'] as Map<String, dynamic>?,
      ),
      deliveryOption: DeliveryOption.fromJsonNullable(
        json['delivery_option'] as Map<String, dynamic>?,
      ),
      shippingAddress: ShippingAddress.fromJsonNullable(
        json['shipping_address'] as Map<String, dynamic>?,
      ),
    );
  }

  static RiderOrderMetadata? fromJsonNullable(Map<String, dynamic>? json) {
    if (json == null) return null;
    return RiderOrderMetadata.fromJson(json);
  }
}

class VendorInfo {
  final bool? isActive;
  final bool? isVendor;
  final int? vendorId;
  final String? kycStatus;
  final String? storeName;
  final String? storeType;
  final String? vendorName;
  final String? vendorEmail;
  final String? vendorPhone;
  final double? storeLatitude;
  final double? storeLongitude;
  final bool? profileIsActive;

  const VendorInfo({
    this.isActive,
    this.isVendor,
    this.vendorId,
    this.kycStatus,
    this.storeName,
    this.storeType,
    this.vendorName,
    this.vendorEmail,
    this.vendorPhone,
    this.storeLatitude,
    this.storeLongitude,
    this.profileIsActive,
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) {
    return VendorInfo(
      isActive: RiderOrder._asBool(json['is_active']),
      isVendor: RiderOrder._asBool(json['is_vendor']),
      vendorId: RiderOrder._asInt(json['vendor_id']),
      kycStatus: RiderOrder._asString(json['kyc_status']),
      storeName: RiderOrder._asString(json['store_name']),
      storeType: RiderOrder._asString(json['store_type']),
      vendorName: RiderOrder._asString(json['vendor_name']),
      vendorEmail: RiderOrder._asString(json['vendor_email']),
      vendorPhone: RiderOrder._asString(json['vendor_phone']),
      storeLatitude: RiderOrder._asDouble(json['store_latitude']),
      storeLongitude: RiderOrder._asDouble(json['store_longitude']),
      profileIsActive: RiderOrder._asBool(json['profile_is_active']),
    );
  }

  static VendorInfo? fromJsonNullable(Map<String, dynamic>? json) {
    if (json == null) return null;
    return VendorInfo.fromJson(json);
  }
}

class OrderPaymentMethod {
  final String? name;
  final String? type;

  const OrderPaymentMethod({this.name, this.type});

  factory OrderPaymentMethod.fromJson(Map<String, dynamic> json) {
    return OrderPaymentMethod(
      name: RiderOrder._asString(json['name']),
      type: RiderOrder._asString(json['type']),
    );
  }

  static OrderPaymentMethod? fromJsonNullable(Map<String, dynamic>? json) {
    if (json == null) return null;
    return OrderPaymentMethod.fromJson(json);
  }
}

class DeliveryOption {
  final String? type;
  final double? price;
  final String? title;
  final String? description;

  const DeliveryOption({
    this.type,
    this.price,
    this.title,
    this.description,
  });

  factory DeliveryOption.fromJson(Map<String, dynamic> json) {
    return DeliveryOption(
      type: RiderOrder._asString(json['type']),
      price: RiderOrder._asDouble(json['price']),
      title: RiderOrder._asString(json['title']),
      description: RiderOrder._asString(json['description']),
    );
  }

  static DeliveryOption? fromJsonNullable(Map<String, dynamic>? json) {
    if (json == null) return null;
    return DeliveryOption.fromJson(json);
  }
}

class ShippingAddress {
  final String? city;
  final String? state;
  final String? country;
  final String? fullName;
  final String? postalCode;
  final String? phoneNumber;
  final String? addressLine1;
  final String? addressLine2;
  final double? latitude;
  final double? longitude;

  const ShippingAddress({
    this.city,
    this.state,
    this.country,
    this.fullName,
    this.postalCode,
    this.phoneNumber,
    this.addressLine1,
    this.addressLine2,
    this.latitude,
    this.longitude,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      city: RiderOrder._asString(json['city']),
      state: RiderOrder._asString(json['state']),
      country: RiderOrder._asString(json['country']),
      fullName: RiderOrder._asString(json['full_name']),
      postalCode: RiderOrder._asString(json['postal_code']),
      phoneNumber: RiderOrder._asString(json['phone_number']),
      addressLine1: RiderOrder._asString(json['address_line1']),
      addressLine2: RiderOrder._asString(json['address_line2']),
      latitude: RiderOrder._asDouble(json['latitude'] ?? json['lat']),
      longitude: RiderOrder._asDouble(json['longitude'] ?? json['lng']),
    );
  }

  static ShippingAddress? fromJsonNullable(Map<String, dynamic>? json) {
    if (json == null) return null;
    return ShippingAddress.fromJson(json);
  }
}
