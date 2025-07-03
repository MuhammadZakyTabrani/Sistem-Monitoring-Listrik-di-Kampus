import 'package:cloud_firestore/cloud_firestore.dart';
import 'alat_model.dart';

class RuangModel {
  final String id;
  final String nama;
  double konsumsi;
  double batas;
  bool aktif;
  DateTime lastUpdated;
  final Map<String, dynamic> metadata;
  final List<AlatModel> daftarAlat;

  RuangModel({
    required this.id,
    required this.nama,
    required this.konsumsi,
    required this.batas,
    required this.aktif,
    required this.metadata,
    DateTime? lastUpdated,
    this.daftarAlat = const [],
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  bool get isOverLimit => konsumsi > batas;

  String get status {
    if (!aktif) return 'Nonaktif';
    if (isOverLimit) return 'Berlebih';
    if (konsumsi > batas * 0.8) return 'Tinggi';
    return 'Normal';
  }

  double get persentasePenggunaan => batas > 0 ? (konsumsi / batas * 100) : 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'konsumsi': konsumsi,
      'batas': batas,
      'aktif': aktif,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'metadata': metadata,
      'daftarAlat': daftarAlat.map((alat) => alat.toJson()).toList(),
    };
  }

  factory RuangModel.fromJson(Map<String, dynamic> json) {
    return RuangModel(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      konsumsi: (json['konsumsi'] ?? 0).toDouble(),
      batas: (json['batas'] ?? 0).toDouble(),
      aktif: json['aktif'] ?? false,
      lastUpdated: json['lastUpdated'] != null
          ? (json['lastUpdated'] as Timestamp).toDate()
          : DateTime.now(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      daftarAlat: json['daftarAlat'] != null
          ? (json['daftarAlat'] as List<dynamic>)
          .map((item) => AlatModel.fromJson(item as Map<String, dynamic>))
          .toList()
          : [],
    );
  }

  RuangModel copyWith({
    String? id,
    String? nama,
    double? konsumsi,
    double? batas,
    bool? aktif,
    DateTime? lastUpdated,
    Map<String, dynamic>? metadata,
    List<AlatModel>? daftarAlat,
  }) {
    return RuangModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      konsumsi: konsumsi ?? this.konsumsi,
      batas: batas ?? this.batas,
      aktif: aktif ?? this.aktif,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      metadata: metadata ?? this.metadata,
      daftarAlat: daftarAlat ?? this.daftarAlat,
    );
  }

  @override
  String toString() {
    return 'RuangModel(id: $id, nama: $nama, konsumsi: $konsumsi, batas: $batas, aktif: $aktif, alat: ${daftarAlat.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RuangModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
