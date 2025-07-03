import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ruang_model.dart';
import '../models/monitoring_data.dart';
import '../models/notifikasi_model.dart';
import '../providers/monitoring_provider.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _monitoringCollection = 'monitoring_data';
  static const String _ruangCollection = 'ruang_data';
  static const String _notifikasiCollection = 'notifications';

  Future<void> forceCreateHistoricalData() async {
    print('🔄 FORCE-CREATING HISTORICAL DATA...');
    try {
      await initializeRoomData();

      final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
      final oldDataSnapshot = await _firestore
          .collection(_monitoringCollection)
          .where('timestamp', isGreaterThanOrEqualTo: cutoffDate)
          .get();

      if (oldDataSnapshot.docs.isNotEmpty) {
        final batchDelete = _firestore.batch();
        for (var doc in oldDataSnapshot.docs) {
          batchDelete.delete(doc.reference);
        }
        await batchDelete.commit();
        print('🗑️ Deleted ${oldDataSnapshot.docs.length} old records to regenerate.');
      }

      await _initializeHistoricalData(monthsBack: 3);
      print('✅ Force-creation of historical data completed!');
    } catch (e) {
      print('❌ Error during force-create historical data: $e');
      rethrow;
    }
  }

  Future<void> initializeRoomData() async {
    try {
      final roomsSnapshot = await _firestore.collection(_ruangCollection).get();
      if (roomsSnapshot.docs.isEmpty) {
        final sampleRooms = _getSampleRoomData();
        final batch = _firestore.batch();
        for (var room in sampleRooms) {
          final docRef = _firestore.collection(_ruangCollection).doc(room['id']);
          batch.set(docRef, room);
        }
        await batch.commit();
        print('✅ Sample room data initialized in Firestore');
      }
    } catch (e) {
      print('❌ Error initializing room data: $e');
      rethrow;
    }
  }

  Future<void> _initializeHistoricalData({int monthsBack = 3}) async {
    try {
      final roomsSnapshot = await _firestore.collection(_ruangCollection).get();
      if (roomsSnapshot.docs.isEmpty) {
        print('⚠️ Room data is empty. Cannot generate historical data.');
        return;
      }

      final monitoringBatch = <MonitoringData>[];
      final now = DateTime.now();

      final roomTypes = <String, RoomSimulationType>{};
      final random = Random();
      final shuffledRooms = List<DocumentSnapshot>.from(roomsSnapshot.docs)..shuffle(random);
      int efficientCount = (shuffledRooms.length * 0.2).round();
      int overLimitCount = (shuffledRooms.length * 0.15).round();

      for (int i = 0; i < shuffledRooms.length; i++) {
        final roomDoc = shuffledRooms[i];
        if (i < efficientCount) {
          roomTypes[roomDoc.id] = RoomSimulationType.alwaysEfficient;
        } else if (i < efficientCount + overLimitCount) {
          roomTypes[roomDoc.id] = RoomSimulationType.alwaysOverLimit;
        } else {
          roomTypes[roomDoc.id] = RoomSimulationType.gradualIncrease;
        }
      }

      for (int month = 0; month < monthsBack; month++) {
        final monthStart = DateTime(now.year, now.month - month, 1);
        final monthEnd = DateTime(now.year, now.month - month + 1, 0, 23, 59, 59);
        final daysInMonth = monthEnd.day;

        for (int day = 1; day <= daysInMonth; day++) {
          final interval = (month == 0) ? 2 : 4;
          for (int hour = 0; hour < 24; hour += interval) {
            final timestamp = DateTime(monthStart.year, monthStart.month, day, hour);
            if (timestamp.isAfter(now)) continue;

            for (var roomDoc in roomsSnapshot.docs) {
              final roomData = roomDoc.data() as Map<String, dynamic>;
              if (roomData['aktif'] as bool) {
                final roomType = roomTypes[roomDoc.id] ?? RoomSimulationType.normal;
                final consumption = _generateHistoricalConsumptionForType(
                    roomData['batas'] as double,
                    timestamp,
                    roomType);
                monitoringBatch.add(MonitoringData(
                  id: '${timestamp.millisecondsSinceEpoch}_${roomData['id'] as String}',
                  ruangId: roomData['id'] as String,
                  ruang: roomData['nama'] as String,
                  daya: consumption,
                  timestamp: timestamp,
                ));
              }
            }
          }
        }
      }
      if (monitoringBatch.isNotEmpty) {
        await saveBatchMonitoringData(monitoringBatch);
        print('✅ Initialized ${monitoringBatch.length} historical records with new patterns.');
      }
    } catch (e) {
      print('❌ Error initializing historical data: $e');
      rethrow;
    }
  }

  double _generateHistoricalConsumptionForType(double batas, DateTime timestamp, RoomSimulationType type) {
    final random = Random(timestamp.millisecondsSinceEpoch);
    final timeMultiplier = _getTimeMultiplier(timestamp.hour);

    switch(type) {
      case RoomSimulationType.alwaysEfficient:
        final ratio = 0.5 + (random.nextDouble() * 0.35);
        return (batas * ratio * timeMultiplier).clamp(batas * 0.1, batas * 0.9);
      case RoomSimulationType.alwaysOverLimit:
        final ratio = 1.05 + (random.nextDouble() * 0.30);
        return (batas * ratio * timeMultiplier).clamp(batas * 1.01, batas * 1.5);
      case RoomSimulationType.gradualIncrease:
      case RoomSimulationType.normal:
        if (timestamp.hour > 9 && timestamp.hour < 17) {
          final ratio = 0.8 + (random.nextDouble() * 0.3);
          return (batas * ratio * timeMultiplier);
        }
        final ratio = 0.6 + (random.nextDouble() * 0.25);
        return (batas * ratio * timeMultiplier);
    }
  }

  double _getTimeMultiplier(int hour) {
    if (hour >= 9 && hour <= 17) return 0.8 + (Random().nextDouble() * 0.2);
    if (hour >= 18 && hour <= 22) return 0.6 - ((hour - 18) * 0.1);
    if (hour >= 6 && hour <= 8) return 0.5 + ((hour - 6) * 0.15);
    return 0.2 + (Random().nextDouble() * 0.1);
  }

  Future<void> saveBatchMonitoringData(List<MonitoringData> dataList) async {
    try {
      const int batchSize = 499;
      for (int i = 0; i < dataList.length; i += batchSize) {
        final batch = _firestore.batch();
        final end = (i + batchSize < dataList.length) ? i + batchSize : dataList.length;
        final batchData = dataList.sublist(i, end);
        for (var data in batchData) {
          final docRef = _firestore.collection(_monitoringCollection).doc(data.id);
          batch.set(docRef, data.toJson());
        }
        await batch.commit();
      }
    } catch (e) {
      print('❌ Error saving batch monitoring data: $e');
      rethrow;
    }
  }

  Stream<List<MonitoringData>> getMonitoringDataStream({int? limitCount = 2000, int? lastHours = 24}) {
    Query query = _firestore.collection(_monitoringCollection);
    if (lastHours != null) {
      final cutoffTime = Timestamp.fromDate(DateTime.now().subtract(Duration(hours: lastHours)));
      query = query.where('timestamp', isGreaterThan: cutoffTime);
    }
    query = query.orderBy('timestamp', descending: true);
    if (limitCount != null) {
      query = query.limit(limitCount);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MonitoringData.fromJson(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Stream<List<RuangModel>> getRoomsStream() {
    return _firestore
        .collection(_ruangCollection)
        .orderBy('nama')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => RuangModel.fromJson(doc.data())).toList());
  }

  Future<void> updateRoomConsumption(String roomId, double consumption) async {
    await _firestore.collection(_ruangCollection).doc(roomId).update({
      'konsumsi': consumption,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateRoomStatus(String id, bool newStatus) async {
    await _firestore.collection(_ruangCollection).doc(id).update({
      'aktif': newStatus,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAlatStatus(String ruangId, String alatId, bool newStatus) async {
    final roomRef = _firestore.collection(_ruangCollection).doc(ruangId);

    await _firestore.runTransaction((transaction) async {
      final roomSnapshot = await transaction.get(roomRef);
      if (!roomSnapshot.exists) {
        throw Exception("Ruangan tidak ditemukan!");
      }

      final roomData = roomSnapshot.data()!;
      final List<dynamic> oldDaftarAlat = roomData['daftarAlat'] ?? [];
      double newTotalKonsumsi = 0;
      bool shouldRoomBeActive = false;

      final newDaftarAlat = oldDaftarAlat.map((alatData) {
        if (alatData['id'] == alatId) {
          alatData['status'] = newStatus;
        }
        if (alatData['status'] == true) {
          newTotalKonsumsi += (alatData['konsumsi'] as num).toDouble();
          shouldRoomBeActive = true; // Jika ada satu saja alat yg aktif, ruangan harus aktif
        }
        return alatData;
      }).toList();

      // Buat map untuk data yang akan diupdate
      final Map<String, dynamic> dataToUpdate = {
        'daftarAlat': newDaftarAlat,
        'konsumsi': newTotalKonsumsi,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      // Hanya update status 'aktif' jika statusnya saat ini berbeda
      if (roomData['aktif'] != shouldRoomBeActive) {
        dataToUpdate['aktif'] = shouldRoomBeActive;
      }

      transaction.update(roomRef, dataToUpdate);
    });
  }

  Future<void> saveNotification(NotifikasiItem notification) async {
    await _firestore.collection(_notifikasiCollection).add(notification.toJson());
  }

  Stream<List<NotifikasiItem>> getNotificationsStream({int limit = 50}) {
    return _firestore
        .collection(_notifikasiCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => NotifikasiItem.fromJson(doc.data())).toList());
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final query = await _firestore.collection(_notifikasiCollection).where('id', isEqualTo: notificationId).get();
    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({'isRead': true});
    }
  }

  List<Map<String, dynamic>> _getSampleRoomData() {
    return [
      {
        'id': '1',
        'nama': 'Ruang Kelas A',
        'konsumsi': 70.0, // Hanya proyektor menyala
        'batas': 300.0,
        'aktif': true,
        'lastUpdated': FieldValue.serverTimestamp(),
        'metadata': {'lokasi': 'Gedung A - Lantai 1', 'kapasitas': '40 mahasiswa', 'tipeSimulasi': 'alwaysEfficient'},
        'daftarAlat': [
          {'id': '1a', 'nama': 'AC Split 1PK', 'konsumsi': 150.0, 'status': false, 'iconName': 'ac_unit'},
          {'id': '1b', 'nama': 'Proyektor Epson', 'konsumsi': 70.0, 'status': true, 'iconName': 'videocam'},
          {'id': '1c', 'nama': 'Lampu LED (5 unit)', 'konsumsi': 50.0, 'status': false, 'iconName': 'lightbulb'},
        ]
      },
      {
        'id': '2',
        'nama': 'Perpustakaan',
        'konsumsi': 30.0, // Hanya server & router menyala
        'batas': 250.0,
        'aktif': true,
        'lastUpdated': FieldValue.serverTimestamp(),
        'metadata': {'lokasi': 'Gedung C - Lantai 1-2', 'kapasitas': '200 pengunjung', 'tipeSimulasi': 'alwaysEfficient'},
        'daftarAlat': [
          {'id': '2a', 'nama': 'AC Central Zone A', 'konsumsi': 150.0, 'status': false, 'iconName': 'ac_unit'},
          {'id': '2b', 'nama': 'Server & Router', 'konsumsi': 30.0, 'status': true, 'iconName': 'router'},
          {'id': '2c', 'nama': 'PC Pustakawan', 'konsumsi': 120.0, 'status': false, 'iconName': 'desktop_windows'},
        ]
      },
      {
        'id': '3',
        'nama': 'Lab Komputer',
        'konsumsi': 575.8, // Semua menyala, melebihi batas
        'batas': 500.0,
        'aktif': true,
        'lastUpdated': FieldValue.serverTimestamp(),
        'metadata': {'lokasi': 'Gedung B - Lantai 2', 'kapasitas': '30 PC', 'tipeSimulasi': 'alwaysOverLimit'},
        'daftarAlat': [
          {'id': '3a', 'nama': 'AC 2PK', 'konsumsi': 200.0, 'status': true, 'iconName': 'ac_unit'},
          {'id': '3b', 'nama': 'PC Unit (10 unit)', 'konsumsi': 350.8, 'status': true, 'iconName': 'desktop_windows'},
          {'id': '3c', 'nama': 'Printer Jaringan', 'konsumsi': 25.0, 'status': true, 'iconName': 'print'},
        ]
      },
      {
        'id': '4',
        'nama': 'Lab Elektronika',
        'konsumsi': 420.2, // Semua menyala, melebihi batas
        'batas': 400.0,
        'aktif': true,
        'lastUpdated': FieldValue.serverTimestamp(),
        'metadata': {'lokasi': 'Gedung B - Lantai 3', 'kapasitas': '25 mahasiswa', 'tipeSimulasi': 'alwaysOverLimit'},
        'daftarAlat': [
          {'id': '4a', 'nama': 'AC 2PK', 'konsumsi': 200.0, 'status': true, 'iconName': 'ac_unit'},
          {'id': '4b', 'nama': 'Peralatan Lab (set)', 'konsumsi': 220.2, 'status': true, 'iconName': 'electrical_services'},
        ]
      },
      {
        'id': '5',
        'nama': 'Ruang Dosen',
        'konsumsi': 100.0, // Hanya AC menyala (kondisi awal normal)
        'batas': 200.0,
        'aktif': true,
        'lastUpdated': FieldValue.serverTimestamp(),
        'metadata': {'lokasi': 'Gedung A - Lantai 2', 'kapasitas': '15 dosen', 'tipeSimulasi': 'gradualIncrease'},
        'daftarAlat': [
          {'id': '5a', 'nama': 'AC 1PK', 'konsumsi': 100.0, 'status': true, 'iconName': 'ac_unit'},
          {'id': '5b', 'nama': 'Komputer Dosen', 'konsumsi': 125.3, 'status': false, 'iconName': 'desktop_windows'},
          {'id': '5c', 'nama': 'TV Presentasi', 'konsumsi': 80.0, 'status': false, 'iconName': 'tv'},
        ]
      },
      {
        'id': '7',
        'nama': 'Aula Utama',
        'konsumsi': 0.0,
        'batas': 800.0,
        'aktif': false,
        'lastUpdated': FieldValue.serverTimestamp(),
        'metadata': {'lokasi': 'Gedung D - Lantai 1', 'kapasitas': '500 orang', 'tipeSimulasi': 'normal'},
        'daftarAlat': [
          {'id': '7a', 'nama': 'AC Central Aula', 'konsumsi': 450.0, 'status': false, 'iconName': 'ac_unit'},
          {'id': '7b', 'nama': 'Sound System', 'konsumsi': 150.0, 'status': false, 'iconName': 'router'},
          {'id': '7c', 'nama': 'Lighting System', 'konsumsi': 200.0, 'status': false, 'iconName': 'lightbulb'},
        ]
      },
    ];
  }
}
