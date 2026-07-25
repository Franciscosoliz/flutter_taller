// lib/domain/model/service.dart

class ServiceCategory {
  final int id;
  final String name;

  const ServiceCategory({
    required this.id,
    required this.name,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> j) => ServiceCategory(
        id: j['id'] as int,
        name: j['nombre'] as String? ?? j['name'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class Service {
  final int id;
  final String name; // Nombre del servicio/reparación
  final String description; // Detalle del trabajo
  final double price; // Precio base
  final double priceWithTax; // Precio con IVA
  final bool isActive;
  final String? imageUrl;
  final ServiceCategory? category;
  final String createdAt;

  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.priceWithTax,
    required this.isActive,
    this.imageUrl,
    this.category,
    required this.createdAt,
  });

  factory Service.fromJson(Map<String, dynamic> j) {
    // 1. Extraer precio parseando string o num (maneja "30.00" de Django)
    final rawPrice = j['precio_referencial'] ?? j['price'];
    final parsedPrice = double.tryParse(rawPrice?.toString() ?? '') ?? 0.0;

    // 2. Si no viene price_with_tax, se calcula el 15% IVA
    final rawTaxPrice = j['price_with_tax'];
    final parsedTaxPrice = rawTaxPrice != null
        ? (double.tryParse(rawTaxPrice.toString()) ?? 0.0)
        : (parsedPrice * 1.15);

    return Service(
      id: j['id'] as int,
      name: j['nombre'] as String? ?? j['name'] as String? ?? '',
      description: j['descripcion'] as String? ?? j['description'] as String? ?? '',
      price: parsedPrice,
      priceWithTax: parsedTaxPrice,
      isActive: j['activo'] as bool? ?? j['is_active'] as bool? ?? true,
      imageUrl: j['foto'] as String? ?? j['image_url'] as String?,
      category: j['category'] != null
          ? ServiceCategory.fromJson(j['category'] as Map<String, dynamic>)
          : null,
      createdAt: j['creado_en'] as String? ?? j['created_at'] as String? ?? '',
    );
  }

  /// Formato estándar en Flutter / cache local
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'price_with_tax': priceWithTax,
        'is_active': isActive,
        'image_url': imageUrl,
        'category': category?.toJson(),
        'created_at': createdAt,
      };

  /// Formato requerido por Django REST Framework para POST / PATCH
  Map<String, dynamic> toDjangoJson() => {
        'nombre': name,
        'descripcion': description,
        'precio_referencial': price.toStringAsFixed(2),
        'activo': isActive,
        'visible_publicamente': true,
      };

  Service copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    double? priceWithTax,
    bool? isActive,
    String? imageUrl,
    ServiceCategory? category,
    String? createdAt,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      priceWithTax: priceWithTax ?? this.priceWithTax,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Service.empty() {
    return const Service(
      id: 0,
      name: '',
      description: '',
      price: 0.0,
      priceWithTax: 0.0,
      isActive: true,
      imageUrl: null,
      category: null,
      createdAt: '',
    );
  }
}