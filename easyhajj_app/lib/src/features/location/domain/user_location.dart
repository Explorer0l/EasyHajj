import 'package:hive/hive.dart';

class UserLocation {
  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
    required this.timezone,
    required this.collectedAt,
  });

  final double latitude;

  final double longitude;

  final String city;

  final String country;

  final String timezone;

  final DateTime collectedAt;

  String get displayName {
    if (city.isEmpty && country.isEmpty) {
      return 'Неизвестное местоположение';
    }
    if (country.isEmpty) return city;
    if (city.isEmpty) return country;
    return '$city, $country';
  }

  UserLocation copyWith({
    double? latitude,
    double? longitude,
    String? city,
    String? country,
    String? timezone,
    DateTime? collectedAt,
  }) {
    return UserLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      country: country ?? this.country,
      timezone: timezone ?? this.timezone,
      collectedAt: collectedAt ?? this.collectedAt,
    );
  }
}

class UserLocationAdapter extends TypeAdapter<UserLocation> {
  @override
  final int typeId = 1;

  @override
  UserLocation read(BinaryReader reader) {
    final latitude = reader.readDouble();
    final longitude = reader.readDouble();
    final city = reader.readString();
    final country = reader.readString();
    final timezone = reader.readString();
    final collectedAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    return UserLocation(
      latitude: latitude,
      longitude: longitude,
      city: city,
      country: country,
      timezone: timezone,
      collectedAt: collectedAt,
    );
  }

  @override
  void write(BinaryWriter writer, UserLocation obj) {
    writer
      ..writeDouble(obj.latitude)
      ..writeDouble(obj.longitude)
      ..writeString(obj.city)
      ..writeString(obj.country)
      ..writeString(obj.timezone)
      ..writeInt(obj.collectedAt.millisecondsSinceEpoch);
  }
}

