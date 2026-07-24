// lib/domain/model/vehicle.dart
class Vehicle {
  final int id;
  final String plate;       // Placa del auto
  final String brand;       // Marca (ej. Toyota)
  final String model;       // Modelo (ej. Corolla)
  final int year;          // Año
  final String? color;
  final String ownerName;   // Nombre del dueño/cliente
  final String createdAt;

  const Vehicle({
    required this.id,
    required this.plate,
    required this.brand,
    required this.model,
    required this.year,
    this.color,
    required this.ownerName,
    required this.createdAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> j) => Vehicle(
        id: j['id'] as int,
        plate: j['plate'] as String,
        brand: j['brand'] as String,
        model: j['model'] as String,
        year: j['year'] as int,
        color: j['color'] as String?,
        ownerName: j['owner_name'] ?? j['username'] ?? '',
        createdAt: j['created_at'] as String,
      );

  Map<String, dynamic> toJson() => {
        'plate': plate,
        'brand': brand,
        'model': model,
        'year': year,
        'color': color,
      };
}