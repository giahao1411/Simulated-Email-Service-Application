import 'package:cloud_firestore/cloud_firestore.dart';

DateTime parseToDateTime(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  } else if (value is DateTime) {
    return value;
  } else if (value is String) {
    // Try parsing ISO8601 string
    return DateTime.parse(value);
  } else {
    throw ArgumentError('Cannot convert $value to DateTime');
  }
}
