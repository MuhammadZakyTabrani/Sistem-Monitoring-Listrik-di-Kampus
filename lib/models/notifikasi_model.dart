import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum NotifikasiType {
  info,
  warning,
  error,
  success,
}

class NotifikasiItem {
  final String id;
  final String judul;
  final String isi;
  final NotifikasiType type;
  final DateTime createdAt;
  final String? ruangId;
  final bool isRead;
  final Map<String, dynamic> metadata;

  NotifikasiItem({
    required this.id,
    required this.judul,
    required this.isi,
    required this.type,
    DateTime? createdAt,
    this.ruangId,
    this.isRead = false,
    Map<String, dynamic>? metadata,
  }) : createdAt = createdAt ?? DateTime.now(),
        metadata = metadata ?? {};

  bool get isPeringatan => type == NotifikasiType.warning || type == NotifikasiType.error;

  Color get typeColor {
    switch (type) {
      case NotifikasiType.info:
        return Colors.blue;
      case NotifikasiType.warning:
        return Colors.orange;
      case NotifikasiType.error:
        return Colors.red;
      case NotifikasiType.success:
        return Colors.green;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case NotifikasiType.info:
        return Icons.info_outline;
      case NotifikasiType.warning:
        return Icons.warning_amber_outlined;
      case NotifikasiType.error:
        return Icons.error_outline;
      case NotifikasiType.success:
        return Icons.check_circle_outline;
    }
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  String get typeText {
    switch (type) {
      case NotifikasiType.info:
        return 'Info';
      case NotifikasiType.warning:
        return 'Peringatan';
      case NotifikasiType.error:
        return 'Error';
      case NotifikasiType.success:
        return 'Berhasil';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'type': type.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'ruangId': ruangId,
      'isRead': isRead,
      'metadata': metadata,
    };
  }

  factory NotifikasiItem.fromJson(Map<String, dynamic> json) {
    return NotifikasiItem(
      id: json['id'] ?? '',
      judul: json['judul'] ?? '',
      isi: json['isi'] ?? '',
      type: NotifikasiType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotifikasiType.info,
      ),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      ruangId: json['ruangId'],
      isRead: json['isRead'] ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  NotifikasiItem copyWith({
    String? id,
    String? judul,
    String? isi,
    NotifikasiType? type,
    DateTime? createdAt,
    String? ruangId,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return NotifikasiItem(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      ruangId: ruangId ?? this.ruangId,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'NotifikasiItem(id: $id, judul: $judul, type: $type, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotifikasiItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
