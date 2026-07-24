// lib/domain/model/category.dart

class Category {
  final int id;
  final String name;
  final String? description;
  final String? price;
  final int? totalProducts; // Para mantener compatibilidad si el backend envía conteos

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.totalProducts,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      // Soporta los nombres 'nombre' o 'name' según como venga en la respuesta de Django
      name: (json['nombre'] ?? json['name'] ?? '') as String,
      description: (json['descripcion'] ?? json['description']) as String?,
      price: json['precio']?.toString() ?? json['price']?.toString(),
      totalProducts: (json['total_servicios'] ?? json['total_products'] ?? 0) as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': name,
      'descripcion': description,
      'precio': price,
    };
  }
}