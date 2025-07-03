import 'package:cloud_firestore/cloud_firestore.dart';

class MonitoringData {
  final String id;
  final String ruangId;
  final String ruang;
  final double daya;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  MonitoringData({
    required this.id,
    required this.ruangId,
    required this.ruang,
    required this.daya,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) : timestamp = timestamp ?? DateTime.now(),
        metadata = metadata ?? {};

  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  String get statusColor {
    if (daya < 100) return 'green';
    if (daya < 300) return 'yellow';
    if (daya < 500) return 'orange';
    return 'red';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ruangId': ruangId,
      'ruang': ruang,
      'daya': daya,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }

  factory MonitoringData.fromJson(Map<String, dynamic> json) {
    return MonitoringData(
      id: json['id'] ?? '',
      ruangId: json['ruangId'] ?? '',
      ruang: json['ruang'] ?? '',
      daya: (json['daya'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  MonitoringData copyWith({
    String? id,
    String? ruangId,
    String? ruang,
    double? daya,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return MonitoringData(
      id: id ?? this.id,
      ruangId: ruangId ?? this.ruangId,
      ruang: ruang ?? this.ruang,
      daya: daya ?? this.daya,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'MonitoringData(id: $id, ruang: $ruang, daya: $daya, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MonitoringData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
