// lib/core/utils/formatters.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/model/work_order.dart';
import '../../theme/app_colors.dart';

String formatPrice(double value, {String currency = '\$'}) =>
    '$currency${value.toStringAsFixed(2)}';

String formatPriceStr(String value, {String currency = '\$'}) {
  final num = double.tryParse(value) ?? 0.0;
  return formatPrice(num, currency: currency);
}

String formatDate(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    return DateFormat('dd MMM yyyy', 'es').format(dt);
  } catch (_) {
    return iso.length >= 10 ? iso.substring(0, 10) : iso;
  }
}

String formatDateTime(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    return DateFormat('dd MMM yyyy · HH:mm', 'es').format(dt);
  } catch (_) {
    return iso.length >= 16 ? iso.substring(0, 16) : iso;
  }
}

String truncate(String text, int max) =>
    text.length <= max ? text : '${text.substring(0, max).trimRight()}…';

Color orderStatusColor(WorkOrderStatus status) {
  switch (status) {
    case WorkOrderStatus.pending:   return AppColors.statusPending;
    case WorkOrderStatus.inProcess: return AppColors.statusInProcess;
    case WorkOrderStatus.ready:     return AppColors.statusReady;
    case WorkOrderStatus.delivered: return AppColors.statusDelivered;
    case WorkOrderStatus.cancelled: return AppColors.statusCancelled;
  }
}