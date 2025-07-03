import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/alat_model.dart';
import '../models/ruang_model.dart';
import '../models/monitoring_data.dart';
import '../models/notifikasi_model.dart';
import '../services/firestore_service.dart';

enum RoomSimulationType {
  alwaysEfficient,
  alwaysOverLimit,
  gradualIncrease,
  normal
}

class TrendData {
  final double currentValue;
  final double previousValue;
  final double percentage;
  final bool isIncreasing;
  final String period;
  final DateTime calculatedAt;

  TrendData({
    required this.currentValue,
    required this.previousValue,
    required this.percentage,
    required this.isIncreasing,
    required this.period,
    required this.calculatedAt,
  });

  bool get hasSignificantChange => percentage.abs() >= 1.0;
}

class MonitoringProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final Map<String, RoomSimulationType> _roomTypes = {};
  final Map<String, double> _gradualIncreaseFactors = {};
  final Map<String, DateTime> _gradualStartTimes = {};
  final List<RuangModel> _ruangList = [];
  final List<MonitoringData> _dataList = [];
  final List<NotifikasiItem> _notifikasiList = [];
  final Map<String, TrendData> _roomTrendCache = {};
  final Map<String, double> _previousRoomConsumptions = {};
  final Map<String, TrendData> _trendCache = {};
  DateTime _lastTrendCalculation = DateTime.now().subtract(const Duration(hours: 1));
  final Random _random = Random();
  bool _isSimulationRunning = true;
  bool _isInitialized = false;
  bool _isLoading = true;
  List<MonitoringData> monitoringData = [];
  double _previousHourConsumption = 0.0;
  double _previousDayConsumption = 0.0;
  double _previousWeekConsumption = 0.0;
  double _previousHourEfficiency = 0.0;
  double _previousDayEfficiency = 0.0;
  int _previousHourActiveRooms = 0;
  int _previousDayActiveRooms = 0;
  StreamSubscription? _roomsSubscription;
  StreamSubscription? _monitoringSubscription;
  StreamSubscription? _notificationsSubscription;
  Timer? _simulationTimer;
  Timer? _trendCalculationTimer;

  final List<MonitoringData> _monitoringDataBatch = [];
  Timer? _persistenceTimer;

  List<RuangModel> get ruangList => List.unmodifiable(_ruangList);
  List<NotifikasiItem> get notifikasiList => List.unmodifiable(_notifikasiList);
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isSimulationRunning => _isSimulationRunning;
  List<MonitoringData> get dataList => List.unmodifiable(_dataList);

  double get totalKonsumsi {
    if (_ruangList.isEmpty) return 0.0;
    return _ruangList
        .where((ruang) => ruang.aktif && ruang.konsumsi > 0)
        .fold(0.0, (sum, ruang) => sum + ruang.konsumsi);
  }

  double get realTimeConsumption => totalKonsumsi;
  double get rataRataKonsumsi {
    final activeRooms = _ruangList.where((ruang) => ruang.aktif).toList();
    if (activeRooms.isEmpty) return 0.0;
    return totalKonsumsi / activeRooms.length;
  }
  double get totalBatas => _ruangList
      .where((ruang) => ruang.aktif && ruang.konsumsi > 0)
      .fold(0.0, (sum, ruang) => sum + ruang.batas);

  int get ruangAktif => _ruangList.where((ruang) => ruang.aktif).length;
  int get ruangOverLimit => _ruangList.where((ruang) => ruang.isOverLimit && ruang.aktif).length;
  int get ruangMendekatiLimit => _ruangList.where((ruang) => ruang.aktif && !ruang.isOverLimit && (ruang.konsumsi / (ruang.batas > 0 ? ruang.batas : 1)) > 0.8).length;
  double get efisiensiEnergi {
    if (totalBatas == 0) return 0.0;
    return ((1 - (totalKonsumsi / totalBatas)) * 100).clamp(0.0, 100.0);
  }
  int get unreadNotificationCount => _notifikasiList.where((notif) => !notif.isRead).length;
  String get totalKonsumsiFormatted => totalKonsumsi.toStringAsFixed(1);
  String get rataRataKonsumsiFormatted => rataRataKonsumsi.toStringAsFixed(1);
  String get efisiensiEnergiFormatted => efisiensiEnergi.toStringAsFixed(1);
  String get ruangAktifFormatted => ruangAktif.toString();
  String get ruangOverLimitFormatted => ruangOverLimit.toString();

  TrendData? getTrendData(String metricKey) => _trendCache[metricKey];
  TrendData getRoomTrend(String roomId) {
    if (_roomTrendCache.containsKey(roomId)) { return _roomTrendCache[roomId]!; }
    return TrendData(currentValue: 0, previousValue: 0, percentage: 0, isIncreasing: false, period: 'realtime', calculatedAt: DateTime.now());
  }

  TrendData? get totalConsumptionTrend => _trendCache['total_consumption'];
  TrendData? get averageConsumptionTrend => _trendCache['average_consumption'];
  TrendData? get efficiencyTrend => _trendCache['efficiency'];
  TrendData? get activeRoomsTrend => _trendCache['active_rooms'];
  TrendData? get overLimitRoomsTrend => _trendCache['over_limit_rooms'];
  TrendData? get dailyEnergyTrend => _trendCache['daily_energy'];
  double? get totalConsumptionTrendPercentage => totalConsumptionTrend?.percentage;
  bool get totalConsumptionIsIncreasing => totalConsumptionTrend?.isIncreasing ?? true;
  double? get efficiencyTrendPercentage => efficiencyTrend?.percentage;
  bool get efficiencyIsIncreasing => efficiencyTrend?.isIncreasing ?? true;
  double? get activeRoomsTrendPercentage => activeRoomsTrend?.percentage;
  bool get activeRoomsIsIncreasing => activeRoomsIsIncreasing ?? true;
  double? get dailyEnergyTrendPercentage => dailyEnergyTrend?.percentage;
  bool get dailyEnergyIsIncreasing => dailyEnergyTrend?.isIncreasing ?? true;

  double get todayConsumption {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayData = _dataList.where((data) => data.timestamp.isAfter(todayStart)).toList();
    return _calculateEnergyFromFirebaseData(todayData);
  }

  double get monthlyConsumption {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthData = _dataList.where((data) => data.timestamp.isAfter(monthStart)).toList();
    return _calculateEnergyFromFirebaseData(monthData);
  }

  double get yesterdayConsumption {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayStart = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final yesterdayEnd = yesterdayStart.add(const Duration(days: 1));
    final yesterdayData = _dataList.where((data) => data.timestamp.isAfter(yesterdayStart) && data.timestamp.isBefore(yesterdayEnd)).toList();
    return _calculateEnergyFromFirebaseData(yesterdayData);
  }

  double get previousHourConsumption {
    final now = DateTime.now();
    final previousHourStart = now.subtract(const Duration(hours: 2));
    final previousHourEnd = now.subtract(const Duration(hours: 1));
    final data = _dataList.where((data) => data.timestamp.isAfter(previousHourStart) && data.timestamp.isBefore(previousHourEnd)).toList();
    return _calculateEnergyFromFirebaseData(data);
  }

  double get previousWeekConsumption {
    final now = DateTime.now();
    final previousWeekStart = now.subtract(const Duration(days: 14));
    final previousWeekEnd = now.subtract(const Duration(days: 7));
    final data = _dataList.where((data) => data.timestamp.isAfter(previousWeekStart) && data.timestamp.isBefore(previousWeekEnd)).toList();
    return _calculateEnergyFromFirebaseData(data);
  }

  double _calculateEnergyFromFirebaseData(List<MonitoringData> data) {
    if (data.isEmpty) return 0.0;
    final groupedByRoom = <String, List<MonitoringData>>{};
    for (var item in data) { groupedByRoom.putIfAbsent(item.ruangId, () => []).add(item); }
    double totalEnergy = 0.0;
    for (var roomData in groupedByRoom.values) {
      roomData.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      for (int i = 1; i < roomData.length; i++) {
        final prev = roomData[i - 1];
        final curr = roomData[i];
        final durationHours = curr.timestamp.difference(prev.timestamp).inSeconds / 3600.0;
        if (durationHours > 6.0) continue;
        final avgPower = (prev.daya + curr.daya) / 2;
        final energy = avgPower * durationHours;
        totalEnergy += energy;
      }
    }
    return totalEnergy / 1000;
  }

  Map<String, double> getMonthlyConsumptionForChart({String? roomId}) {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final previousMonth = DateTime(now.year, now.month - 1, 1);
    final previousMonthStart = DateTime(previousMonth.year, previousMonth.month, 1);
    final List<MonitoringData> relevantData = (roomId == null) ? _dataList : _dataList.where((d) => d.ruangId == roomId).toList();
    final currentMonthData = relevantData.where((data) => data.timestamp.isAfter(currentMonthStart)).toList();
    final previousMonthData = relevantData.where((data) => data.timestamp.isAfter(previousMonthStart) && data.timestamp.isBefore(currentMonthStart)).toList();
    return { 'current': _calculateEnergyFromFirebaseData(currentMonthData), 'previous': _calculateEnergyFromFirebaseData(previousMonthData), };
  }

  double get dailyConsumptionChange {
    final today = todayConsumption;
    final yesterday = yesterdayConsumption;
    if (yesterday == 0) return today > 0 ? 100.0 : 0.0;
    return ((today - yesterday) / yesterday) * 100;
  }

  double get currentTotalConsumption => totalKonsumsi;
  String get currentTotalConsumptionFormatted => currentTotalConsumption.toStringAsFixed(1);

  double get estimatedDailyConsumption {
    if (todayConsumption <= 0) return 0.0;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final elapsedHours = now.difference(todayStart).inHours.toDouble();
    if (elapsedHours <= 0) return 0.0;
    final hourlyAverage = todayConsumption / elapsedHours;
    return hourlyAverage * 24;
  }

  String get estimatedDailyConsumptionFormatted => estimatedDailyConsumption.toStringAsFixed(1);

  Map<String, dynamic> getComprehensiveMetrics() { return {}; }
  Map<String, dynamic> getRoomSimulationInfo() { return {}; }

  // FUNGSI INTI

  MonitoringProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    _isLoading = true;
    notifyListeners();
    try {
      print('🚀 Initializing MonitoringProvider...');
      await _firestoreService.initializeRoomData();
      await _setupFirebaseListeners();
      print('✅ Firebase listeners setup');

      _startSimulasi();
      _startPersistenceTimer();
      _startTrendCalculation();

      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
      print('✅ MonitoringProvider fully initialized');
    } catch (e) {
      print('❌ Error initializing MonitoringProvider: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetSimulationTypes() {
    _roomTypes.clear();
    _gradualIncreaseFactors.clear();
    _gradualStartTimes.clear();
    _initializeRoomSimulationTypes();
    notifyListeners();
  }

  void _startTrendCalculation() {
    _trendCalculationTimer?.cancel();
    _trendCalculationTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_isInitialized && _ruangList.isNotEmpty) {
        _calculateTrends();
        notifyListeners();
      }
    });
  }

  Future<void> _setupFirebaseListeners() async {
    _roomsSubscription?.cancel();
    _monitoringSubscription?.cancel();
    _notificationsSubscription?.cancel();
    _roomsSubscription = _firestoreService.getRoomsStream().listen((rooms) {
      final isFirstLoad = _ruangList.isEmpty;
      _mergeRoomData(rooms);
      if (isFirstLoad && rooms.isNotEmpty) {
        _initializeRoomSimulationTypes();
      }
      notifyListeners();
    });
    _monitoringSubscription = _firestoreService.getMonitoringDataStream(limitCount: 2500, lastHours: 24 * 90).listen((data) {
      _dataList.clear();
      _dataList.addAll(data);
      monitoringData = _dataList;
      _dataList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    });
    _notificationsSubscription = _firestoreService.getNotificationsStream(limit: 50).listen((notifications) {
      _notifikasiList.clear();
      _notifikasiList.addAll(notifications);
      notifyListeners();
    });
  }

  void _mergeRoomData(List<RuangModel> firebaseRooms) {
    if (firebaseRooms.isEmpty && _ruangList.isNotEmpty) { return; }
    for (var firebaseRoom in firebaseRooms) {
      final existingIndex = _ruangList.indexWhere((r) => r.id == firebaseRoom.id);
      if (existingIndex >= 0) {
        final existing = _ruangList[existingIndex];
        if (existing.lastUpdated.isAfter(firebaseRoom.lastUpdated)) {
          firebaseRoom.konsumsi = existing.konsumsi;
          firebaseRoom.lastUpdated = existing.lastUpdated;
          firebaseRoom.daftarAlat.clear();
          firebaseRoom.daftarAlat.addAll(existing.daftarAlat);
        }
        _ruangList[existingIndex] = firebaseRoom;
      } else {
        _ruangList.add(firebaseRoom);
      }
    }
    _ruangList.removeWhere((local) => !firebaseRooms.any((firebase) => firebase.id == local.id));
  }

  void _calculateTrends() {
    final now = DateTime.now();
    if (now.difference(_lastTrendCalculation).inMinutes < 1 && _trendCache.isNotEmpty && _roomTrendCache.isNotEmpty) return;
    final currentEfficiency = efisiensiEnergi;
    if (_previousHourEfficiency > 0) {
      final percentage = ((currentEfficiency - _previousHourEfficiency) / _previousHourEfficiency) * 100;
      _trendCache['efficiency'] = TrendData(currentValue: currentEfficiency, previousValue: _previousHourEfficiency, percentage: percentage, isIncreasing: percentage > 0, period: 'hourly', calculatedAt: now);
    }
    _previousHourEfficiency = currentEfficiency;
    for (final ruang in _ruangList) {
      if (!ruang.aktif) continue;
      final currentRoomConsumption = ruang.konsumsi;
      final previousRoomConsumption = _previousRoomConsumptions[ruang.id] ?? 0.0;
      if (previousRoomConsumption > 0) {
        final percentage = ((currentRoomConsumption - previousRoomConsumption) / previousRoomConsumption) * 100;
        _roomTrendCache[ruang.id] = TrendData(currentValue: currentRoomConsumption, previousValue: previousRoomConsumption, percentage: percentage, isIncreasing: percentage > 0, period: 'realtime', calculatedAt: now);
      }
      _previousRoomConsumptions[ruang.id] = currentRoomConsumption;
    }
    _lastTrendCalculation = now;
  }

  void _initializeRoomSimulationTypes() {
    if (_ruangList.isEmpty) return;
    print("🧠 Assigning simulation types based on metadata...");

    for (var ruang in _ruangList) {
      final tipe = ruang.metadata['tipeSimulasi'];
      switch (tipe) {
        case 'alwaysEfficient':
          _roomTypes[ruang.id] = RoomSimulationType.alwaysEfficient;
          break;
        case 'alwaysOverLimit':
          _roomTypes[ruang.id] = RoomSimulationType.alwaysOverLimit;
          break;
        case 'gradualIncrease':
          _roomTypes[ruang.id] = RoomSimulationType.gradualIncrease;
          _gradualStartTimes[ruang.id] = DateTime.now();
          break;
        default:
          _roomTypes[ruang.id] = RoomSimulationType.normal;
          break;
      }
    }
    print("Room types assigned: $_roomTypes");
  }

  void _startSimulasi() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_isSimulationRunning && _isInitialized && _ruangList.isNotEmpty) {
        _updateSimulationDataLocally();
        await _checkForAlerts();
        _calculateTrends();
      }
    });
  }

  void _updateSimulationDataLocally() {
    bool needsUiUpdate = false;
    for (var ruang in _ruangList) {
      if (!ruang.aktif) continue;
      final type = _roomTypes[ruang.id] ?? RoomSimulationType.normal;
      bool hasChanged = _applySimulationRule(ruang, type);
      if (hasChanged) {
        ruang.konsumsi = _calculateRoomConsumption(ruang);
        ruang.lastUpdated = DateTime.now();
        final logEntry = MonitoringData(id: '${ruang.lastUpdated.millisecondsSinceEpoch}_${ruang.id}', ruangId: ruang.id, ruang: ruang.nama, daya: ruang.konsumsi, timestamp: ruang.lastUpdated);
        _monitoringDataBatch.add(logEntry);
        needsUiUpdate = true;
      }
    }
    if (needsUiUpdate) {
      notifyListeners();
    }
  }

  bool _applySimulationRule(RuangModel ruang, RoomSimulationType type) {
    bool hasChanged = false;
    switch(type) {
      case RoomSimulationType.alwaysEfficient:
        for (var alat in ruang.daftarAlat) {
          if (alat.konsumsi > 150 && alat.status && _random.nextDouble() < 0.3) {
            alat.status = false; hasChanged = true;
          } else if (alat.konsumsi <= 100 && !alat.status && _random.nextDouble() < 0.1) {
            alat.status = true; hasChanged = true;
          }
        }
        break;
      case RoomSimulationType.alwaysOverLimit:
        for (var alat in ruang.daftarAlat) {
          if (!alat.status && _random.nextDouble() < 0.25) {
            alat.status = true; hasChanged = true;
          }
        }
        break;
      case RoomSimulationType.gradualIncrease:
        final startTime = _gradualStartTimes[ruang.id] ?? DateTime.now();
        final minutesPassed = DateTime.now().difference(startTime).inMinutes;
        final turnOnProbability = 0.05 + (minutesPassed / 5) * 0.05;
        for (var alat in ruang.daftarAlat) {
          if (!alat.status && _random.nextDouble() < turnOnProbability.clamp(0.05, 0.4)) {
            alat.status = true; hasChanged = true;
          }
        }
        break;
      case RoomSimulationType.normal:
        for (var alat in ruang.daftarAlat) {
          if (_random.nextDouble() < 0.1) {
            alat.status = !alat.status; hasChanged = true;
          }
        }
        break;
    }
    return hasChanged;
  }

  Future<void> toggleAlatStatus(String ruangId, String alatId) async {
    final ruangIndex = _ruangList.indexWhere((r) => r.id == ruangId);
    if (ruangIndex == -1) return;
    final ruang = _ruangList[ruangIndex];
    final alatIndex = ruang.daftarAlat.indexWhere((a) => a.id == alatId);
    if (alatIndex == -1) return;

    final alat = ruang.daftarAlat[alatIndex];
    alat.status = !alat.status;

    // sinkronisasi status 'aktif' ruangan
    if (alat.status == true && ruang.aktif == false) {
      ruang.aktif = true;
    }

    ruang.konsumsi = _calculateRoomConsumption(ruang);
    ruang.lastUpdated = DateTime.now();
    _calculateTrends();
    notifyListeners();

    try {
      await _firestoreService.updateAlatStatus(ruangId, alatId, alat.status);
    } catch (e) {
      // Rollback jika gagal
      alat.status = !alat.status;
      ruang.konsumsi = _calculateRoomConsumption(ruang);
      _calculateTrends();
      notifyListeners();
    }
  }

  double _calculateRoomConsumption(RuangModel ruang) {
    return ruang.daftarAlat.where((alat) => alat.status).fold(0.0, (sum, alat) => sum + alat.konsumsi);
  }

  void _startPersistenceTimer() {
    _persistenceTimer?.cancel();
    _persistenceTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_isInitialized && _monitoringDataBatch.isNotEmpty) {
        _persistDataToFirestore();
      }
    });
  }

  Future<void> _persistDataToFirestore() async {
    if (_monitoringDataBatch.isEmpty) return;
    print('🔄 Persisting data to Firestore...');
    try {
      final Set<String> updatedRoomIds = _monitoringDataBatch.map((d) => d.ruangId).toSet();
      final roomsToUpdate = _ruangList.where((r) => updatedRoomIds.contains(r.id)).toList();
      final updateFutures = roomsToUpdate.map((r) => _firestoreService.updateRoomConsumption(r.id, r.konsumsi)).toList();
      await Future.wait(updateFutures);
      await _firestoreService.saveBatchMonitoringData(_monitoringDataBatch);
      _monitoringDataBatch.clear();
      print('✅ Persisted data batch.');
    } catch (e) {
      print('❌ Error during periodic persistence: $e');
    }
  }

  Future<void> _checkForAlerts() async {
    if (_ruangList.isEmpty) return;
    for (var ruang in _ruangList) {
      if (!ruang.aktif) continue;
      final consumptionRatio = ruang.konsumsi / (ruang.batas > 0 ? ruang.batas : 1);
      if (ruang.isOverLimit) {
        await _addNotifikasi(judul: '⚠️ Konsumsi Berlebih!', isi: '${ruang.nama} melebihi batas: ${ruang.konsumsi.toStringAsFixed(1)}W > ${ruang.batas.toInt()}W (${(consumptionRatio * 100).toStringAsFixed(1)}%)', type: NotifikasiType.warning, ruangId: ruang.id);
      }
    }
    if (ruangOverLimit >= 3) {
      await _addNotifikasi(judul: '🚨 Peringatan Kampus', isi: '$ruangOverLimit ruangan melebihi batas konsumsi.', type: NotifikasiType.error);
    }
  }

  Future<void> _addNotifikasi({required String judul, required String isi, required NotifikasiType type, String? ruangId}) async {
    if (_isDuplicateNotification(judul, ruangId)) return;
    final notification = NotifikasiItem(id: '${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}', judul: judul, isi: isi, type: type, ruangId: ruangId);
    await _firestoreService.saveNotification(notification);
  }

  bool _isDuplicateNotification(String judul, String? ruangId) {
    final int minutes = (ruangId == null) ? 30 : 10;
    return _notifikasiList.any((notif) => notif.judul == judul && notif.ruangId == ruangId && DateTime.now().difference(notif.createdAt).inMinutes < minutes);
  }

  Future<void> markNotificationAsRead(String id) async {
    await _firestoreService.markNotificationAsRead(id);
  }

  Future<void> toggleRuangAktif(String id) async {
    final ruang = _ruangList.firstWhere((r) => r.id == id);
    await _firestoreService.updateRoomStatus(id, !ruang.aktif);
  }

  RuangModel? getRuangById(String id) {
    try {
      return _ruangList.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  List<MonitoringData> getDataByRuang(String ruangId) {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return _dataList.where((data) => data.ruangId == ruangId && data.timestamp.isAfter(cutoff)).toList();
  }

  Future<void> refreshData() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    await _setupFirebaseListeners();
    await Future.delayed(const Duration(seconds: 2));
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _trendCalculationTimer?.cancel();
    _persistenceTimer?.cancel();
    _roomsSubscription?.cancel();
    _monitoringSubscription?.cancel();
    _notificationsSubscription?.cancel();
    super.dispose();
  }
}
