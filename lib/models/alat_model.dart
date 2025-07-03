import 'package:flutter/material.dart';

/// Model untuk merepresentasikan satu buah alat elektronik.
class AlatModel {
  final String id;
  final String nama;
  final double konsumsi;
  bool status;
  final String iconName;

  AlatModel({
    required this.id,
    required this.nama,
    required this.konsumsi,
    required this.status,
    required this.iconName,
  });

  /// Konversi dari Map (data dari Firestore) menjadi objek AlatModel.
  factory AlatModel.fromJson(Map<String, dynamic> json) {
    return AlatModel(
      id: json['id'] as String,
      nama: json['nama'] as String,
      konsumsi: (json['konsumsi'] as num).toDouble(),
      status: json['status'] as bool,
      iconName: json['iconName'] as String,
    );
  }

  /// Konversi dari objek AlatModel menjadi Map untuk disimpan ke Firestore.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'konsumsi': konsumsi,
      'status': status,
      'iconName': iconName,
    };
  }

  /// Helper untuk membuat salinan objek dengan beberapa perubahan.
  AlatModel copyWith({
    String? id,
    String? nama,
    double? konsumsi,
    bool? status,
    String? iconName,
  }) {
    return AlatModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      konsumsi: konsumsi ?? this.konsumsi,
      status: status ?? this.status,
      iconName: iconName ?? this.iconName,
    );
  }
}

// Helper untuk mendapatkan IconData dari string nama ikon.
IconData getIconData(String iconName) {
  switch (iconName) {
    case 'ac_unit':
      return Icons.ac_unit;
    case 'lightbulb':
      return Icons.lightbulb;
    case 'desktop_windows':
      return Icons.desktop_windows;
    case 'print':
      return Icons.print;
    case 'router':
      return Icons.router;
    case 'tv':
      return Icons.tv;
    case 'videocam':
      return Icons.videocam;
    default:
      return Icons.electrical_services;
  }
}
