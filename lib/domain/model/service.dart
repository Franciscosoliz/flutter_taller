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
        name: j['name'] as String? ?? '',
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

  factory Service.fromJson(Map<String, dynamic> j) => Service(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
        description: j['description'] as String? ?? '',
        price: double.tryParse(j['price'].toString()) ?? 0.0,
        priceWithTax: (j['price_with_tax'] as num?)?.toDouble() ?? 0.0,
        isActive: j['is_active'] as bool? ?? true,
        imageUrl: j['image_url'] as String?,
        category: j['category'] != null
            ? ServiceCategory.fromJson(j['category'] as Map<String, dynamic>)
            : null,
        createdAt: j['created_at'] as String? ?? '',
      );

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