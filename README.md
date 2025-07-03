# ELECON - Sistem Monitoring Listrik Kampus

<div align="center">

![Flutter Version](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart Version](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-9.0+-orange.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

</div>

<p align="center">
 <img src="assets/icon_logo.png" alt="ELECON Logo" width="150"/>
</p>

<p align="center">
 <strong>Sistem Monitoring Konsumsi Listrik Kampus Real-Time</strong>
</p>

## 📱 Tentang ELECON

ELECON adalah aplikasi mobile monitoring konsumsi listrik kampus yang dibangun menggunakan Flutter. Aplikasi ini memungkinkan pengelola fasilitas kampus untuk memantau, menganalisis, dan mengoptimalkan penggunaan energi listrik secara efisien dan berkelanjutan.

### 🎯 Tujuan Utama
- Meningkatkan efisiensi energi di lingkungan kampus
- Mengurangi biaya operasional listrik
- Mendukung program green campus dan keberlanjutan
- Memberikan visibilitas penuh terhadap konsumsi energi

## ✨ Fitur Unggulan

### 📊 Monitoring Real-Time
- Pantau konsumsi listrik setiap ruangan secara langsung
- Dashboard interaktif dengan update data real-time
- Indikator visual status penggunaan energi

### 📈 Analisis & Statistik
- Grafik tren konsumsi listrik harian, mingguan, dan bulanan
- Perbandingan konsumsi antar ruangan dan periode
- Laporan konsumsi energi yang dapat diekspor ke PDF

### 🔔 Sistem Notifikasi
- Peringatan otomatis jika konsumsi melebihi batas normal
- Notifikasi push untuk anomali penggunaan listrik
- Alert pemeliharaan peralatan listrik

### 🏢 Manajemen Perangkat
- QR Code scanner untuk identifikasi peralatan listrik
- Manajemen status ON/OFF perangkat
- Tracking kondisi dan maintenance peralatan

### 📱 Antarmuka Modern
- Material Design 3 dengan UI yang intuitif
- Responsive design untuk berbagai ukuran layar
- Dark mode dan light mode support

## 🛠️ Stack Teknologi

### Frontend
- **Flutter 3.0+** - Cross-platform UI framework
- **Dart 3.0+** - Modern programming language
- **Material Design 3** - Google's design system

### Backend & Database
- **Firebase Firestore** - NoSQL real-time database
- **Firebase Authentication** - User management
- **Firebase Cloud Functions** - Serverless backend logic

### State Management & Architecture
- **Provider** - Lightweight state management
- **MVVM Architecture** - Clean code architecture
- **Dependency Injection** - Modular and testable code

### Libraries & Packages
- **fl_chart** - Interactive charts and graphs
- **qr_code_scanner** - QR code scanning functionality
- **connectivity_plus** - Network connectivity detection
- **pdf** - PDF report generation
- **firebase_messaging** - Push notifications

## 📁 Struktur Proyek

```
lib/
├── main.dart                 # Entry point aplikasi
├── models/                   # Model data
│   ├── alat_model.dart
│   ├── monitoring_data.dart
│   └── ruang_model.dart
├── providers/               # State management
│   └── monitoring_provider.dart
├── screens/                 # UI screens
│   ├── monitoring_screen.dart
│   ├── statistik_screen.dart
│   └── ...
├── services/               # Backend services
│   ├── firestore_service.dart
│   └── pdf_export_service.dart
├── theme/                  # Styling
│   └── colors.dart
├── utils/                  # Helper functions
│   └── utils.dart
└── widgets/               # Reusable components
    ├── alat_card.dart
    ├── bar_chart_widget.dart
    └── ...
```

## 📊 Database Schema

### Collections Firestore

```json
// Collection: ruang_data
{
  "id": "1",
  "nama": "Ruang Kelas A",
  "konsumsi": 70.0,
  "batas": 300.0,
  "aktif": true,
  "lastUpdated": "2024-07-03T10:00:00.000Z",
  "metadata": {
    "lokasi": "Gedung A - Lantai 1",
    "kapasitas": "40 mahasiswa",
    "tipeSimulasi": "alwaysEfficient"
  },
  "daftarAlat": [
    {
      "id": "1a",
      "nama": "AC Split 1PK",
      "konsumsi": 150.0,
      "status": false,
      "iconName": "ac_unit"
    },
    {
      "id": "1b",
      "nama": "Lampu LED",
      "konsumsi": 20.0,
      "status": true,
      "iconName": "light"
    }
  ]
}

// Collection: monitoring_data
{
  "id": "monitoring_001",
  "ruangId": "1",
  "ruang": "Ruang Kelas A",
  "daya": 120.0,
  "timestamp": "2024-07-03T10:00:00.000Z"
}

// Collection: notifications
{
  "id": "notif_001",
  "title": "Konsumsi Listrik Melebihi Batas",
  "message": "Ruang Kelas A telah melebihi batas konsumsi listrik.",
  "ruangId": "1",
  "createdAt": "2024-07-03T10:05:00.000Z",
  "read": false
}
```

## 📈 Roadmap

- [x] Monitoring real-time konsumsi listrik
- [x] Sistem notifikasi dan alert
- [x] QR code scanner untuk perangkat
- [x] Export laporan ke PDF
- [ ] Machine learning untuk prediksi konsumsi
- [ ] Integrasi dengan IoT sensors
- [ ] Multi-language support
- [ ] Web dashboard admin
- [ ] API REST untuk integrasi pihak ketiga

## 📄 Lisensi

Proyek ini dilisensikan di bawah MIT License - lihat file [LICENSE](LICENSE) untuk detail.

## 👥 Tim Pengembang

- **Muhammad Zaky Tabrani** - *Lead Developer* - [@MuhammadZakyTabrani](https://github.com/MuhammadZakyTabrani)

## 📞 Kontak & Dukungan

- **Email:** zakitabrani1004@gmail.com
- **Instagram:** [@zaktabrann](https://www.instagram.com/zaktabrann)
- **Project Link:** [GitHub Repository](https://github.com/MuhammadZakyTabrani/Sistem-Monitoring-Listrik-di-Kampus)

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev) - Amazing cross-platform framework
- [Firebase](https://firebase.google.com) - Comprehensive app development platform
- [Provider Package](https://pub.dev/packages/provider) - State management solution
- [FL Chart](https://pub.dev/packages/fl_chart) - Beautiful chart library
- [QR Code Scanner](https://pub.dev/packages/qr_code_scanner) - QR scanning functionality
- [Material Design](https://material.io/) - Design system and components

---

<div align="center">

**💻 Dibuat dengan ❤️ untuk Tugas Besar Mobile Programming**

*Mendukung Green Campus Initiative & Sustainable Energy Management*

</div>
