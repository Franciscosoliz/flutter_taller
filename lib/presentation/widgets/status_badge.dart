// lib/presentation/widgets/status_badge.dart
import 'package:flutter/material.dart';
import '../../domain/model/work_order.dart';

class StatusBadge extends StatelessWidget {
  final WorkOrderStatus status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getBadgeStyle(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.borderColor, width: 1),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: style.textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  _BadgeStyle _getBadgeStyle(WorkOrderStatus status) {
    switch (status) {
      case WorkOrderStatus.pending:
        return const _BadgeStyle(
          backgroundColor: Color(0x1AFFB000), // Amarillo ámbar semitransparente
          borderColor: Color(0xFFFFB000),
          textColor: Color(0xFFFFB000),
        );
      case WorkOrderStatus.inProcess:
        return const _BadgeStyle(
          backgroundColor: Color(0x1A00B4D8), // Azul cian semitransparente
          borderColor: Color(0x0000B4D8),
          textColor: Color(0xFF00B4D8),
        );
      case WorkOrderStatus.ready:
        return const _BadgeStyle(
          backgroundColor: Color(0x1A7209B7), // Púrpura semitransparente
          borderColor: Color(0xFF7209B7),
          textColor: Color(0xFF9D4EDD),
        );
      case WorkOrderStatus.delivered:
        return const _BadgeStyle(
          backgroundColor: Color(0x1A00E676), // Verde esmeralda semitransparente
          borderColor: Color(0xFF00E676),
          textColor: Color(0xFF00E676),
        );
      case WorkOrderStatus.cancelled:
        return const _BadgeStyle(
          backgroundColor: Color(0x1AFF5252), // Rojo semitransparente
          borderColor: Color(0xFFFF5252),
          textColor: Color(0xFFFF5252),
        );
    }
  }
}

class _BadgeStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const _BadgeStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}