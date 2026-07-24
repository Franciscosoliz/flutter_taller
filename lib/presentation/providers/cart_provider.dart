// lib/presentation/providers/cart_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/service.dart';

class CartItem {
  final Service service;
  final int quantity;

  const CartItem({
    required this.service,
    required this.quantity,
  });

  CartItem copyWith({int? quantity}) => CartItem(
        service: service,
        quantity: quantity ?? this.quantity,
      );

  double get subtotal => service.price * quantity;
  double get totalWithTax => service.priceWithTax * quantity;
}

class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get totalItems => items.fold(0, (s, i) => s + i.quantity);
  double get subtotal => items.fold(0.0, (s, i) => s + i.subtotal);
  double get totalWithTax =>
      items.fold(0.0, (s, i) => s + i.totalWithTax);

  CartState copyWith({List<CartItem>? items}) =>
      CartState(items: items ?? this.items);
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addItem(Service service, {int quantity = 1}) {
    final idx = state.items.indexWhere((i) => i.service.id == service.id);
    if (idx >= 0) {
      final updated = List<CartItem>.from(state.items);
      final newQty = updated[idx].quantity + quantity;
      updated[idx] = updated[idx].copyWith(quantity: newQty);
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(service: service, quantity: quantity),
        ],
      );
    }
  }

  void updateQuantity(int serviceId, int quantity) {
    if (quantity <= 0) {
      removeItem(serviceId);
      return;
    }
    state = state.copyWith(
      items: state.items
          .map((i) =>
              i.service.id == serviceId ? i.copyWith(quantity: quantity) : i)
          .toList(),
    );
  }

  void removeItem(int serviceId) {
    state = state.copyWith(
      items: state.items.where((i) => i.service.id != serviceId).toList(),
    );
  }

  void clearCart() => state = const CartState();
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (_) => CartNotifier(),
);