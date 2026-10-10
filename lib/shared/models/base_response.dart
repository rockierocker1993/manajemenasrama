/// Generic base response model to represent backend responses like:
/// {
///   "response_code": "RC000",
///   "status": true,
///   "message_id": "Sukses",
///   "message_en": "Success",
///   "title_id": "Sukses",
///   "title_en": "Success",
///   "data": { ... } // or null / array / primitive
/// }
///
/// Usage examples:
///   // Parse `data` as a Map
///   final br = BaseResponse<Map<String, dynamic>>.fromJson(json, (d) => Map<String, dynamic>.from(d as Map));
///
///   // Parse `data` as a typed object using a factory `MyModel.fromJson`
///   final br = BaseResponse<MyModel>.fromJson(json, (d) => MyModel.fromJson(Map<String,dynamic>.from(d as Map)));
///
///   // Check success
///   if (!br.isSuccess) throw Exception(br.message ?? 'failed');
///
///   // Access data
///   final model = br.data; // MyModel?

class BaseResponse<T> {
  const BaseResponse({
    this.responseCode,
    this.status,
    this.messageId,
    this.messageEn,
    this.titleId,
    this.titleEn,
    this.message,
    this.data,
  });

  final String? responseCode;
  final bool? status;
  final String? messageId;
  final String? messageEn;
  final String? titleId;
  final String? titleEn;
  final String? message;
  final T? data;

  bool get isSuccess => status == true;

  /// Create from a dynamic JSON-like object. `json` is usually the decoded
  /// body returned by `BackendApiClient._decode` (so it may already be a
  /// Map<String, dynamic> or something else). `fromData` is a converter that
  /// knows how to turn `data` payload into `T`. If `data` is null then
  /// `data` will be null.
  factory BaseResponse.fromJson(dynamic json, T Function(dynamic)? fromData) {
    if (json is! Map<String, dynamic>) {
      // If the response is not a map, return an empty wrapper with null data.
      return BaseResponse<T>(data: null);
    }

    final dataRaw = json['data'];
    T? data;
    if (dataRaw != null && fromData != null) {
      data = fromData(dataRaw);
    }

    return BaseResponse<T>(
      responseCode: json['response_code']?.toString(),
      status: json.containsKey('status') ? (json['status'] == true) : null,
      messageId: json['message_id']?.toString(),
      messageEn: json['message_en']?.toString(),
      titleId: json['title_id']?.toString(),
      titleEn: json['title_en']?.toString(),
      message: (json['message'] ?? json['error'])?.toString(),
      data: data,
    );
  }

  Map<String, dynamic> toJson(Object Function(T)? toData) {
    return {
      if (responseCode != null) 'response_code': responseCode,
      if (status != null) 'status': status,
      if (messageId != null) 'message_id': messageId,
      if (messageEn != null) 'message_en': messageEn,
      if (titleId != null) 'title_id': titleId,
      if (titleEn != null) 'title_en': titleEn,
      if (message != null) 'message': message,
      'data': data == null ? null : (toData != null ? toData(data as T) : data),
    };
  }
}

