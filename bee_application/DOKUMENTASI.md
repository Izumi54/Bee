# 🐝 BEE Bank Digital - Dokumentasi Lengkap

**Versi:** 1.0.0  
**Platform:** Android, iOS, Web, Windows  
**Framework:** Flutter 3.6+  

---

## 📱 Tentang Aplikasi

**BEE** adalah aplikasi Bank Digital modern yang memungkinkan pengguna mengelola keuangan digital dengan mudah dan aman. Aplikasi ini dilengkapi dengan fitur **Pay Later** untuk kemudahan transaksi dengan sistem cicilan.

### Fitur Utama
- ✅ **Bank Digital** - Top up, transfer, dan kelola saldo
- ✅ **Pay Later** - Pinjaman dengan cicilan fleksibel
- ✅ **Transaction History** - Riwayat transaksi lengkap
- ✅ **Security** - PIN 6 digit & Firebase Authentication

---

## 🚀 Cara Menggunakan Aplikasi

### 1️⃣ **Download & Install**

**Untuk Android:**
```
1. Download file bee.apk
2. Buka file APK di perangkat Android
3. Izinkan "Install from Unknown Sources" jika diminta
4. Klik Install
5. Tunggu hingga instalasi selesai
```

**Untuk Development (Flutter):**
```bash
flutter run
```

---

### 2️⃣ **Registrasi Akun Baru**

1. **Buka Aplikasi BEE**
   - Tampilan welcome screen dengan logo Bee
   
2. **Klik "Daftar"**

3. **Isi Data Registrasi:**
   - **Nama Lengkap** (min. 3 karakter)
   - **Email** (format email valid)
   - **Nomor Telepon** (10-13 digit)
   - Centang "Saya setuju dengan syarat dan ketentuan"

4. **Buat PIN 6 Digit**
   - Masukkan PIN (6 angka)
   - Konfirmasi PIN (masukkan ulang)

5. **Registrasi Selesai** ✅
   - Otomatis login ke aplikasi
   - Saldo awal: **Rp 0**

---

### 3️⃣ **Login**

1. **Klik "Masuk"** di welcome screen

2. **Masukkan PIN 6 Digit**
   - PIN yang dibuat saat registrasi

3. **Berhasil Login** → Masuk ke Home Screen

---

### 4️⃣ **Top Up Saldo**

1. **Di Home Screen**, klik **"Top Up"**

2. **Pilih Nominal:**
   - Gunakan quick amount (Rp 50k, 100k, dll)
   - Atau masukkan nominal custom

3. **Pilih Metode Pembayaran:**
   - Virtual Account
   - Bank Digital (GoPay, OVO, dll)
   - Transfer Bank

4. **Konfirmasi Top Up**
   - Review detail transaksi
   - Klik "Konfirmasi"

5. **Saldo Bertambah** ✅

---

### 5️⃣ **Transfer Uang**

1. **Klik "Transfer"** di Home Screen

2. **Pilih Penerima:**
   - Pilih dari daftar kontak
   - Atau tambah kontak baru (nama + nomor rekening)

3. **Masukkan Jumlah Transfer**

4. **Pilih Metode Pembayaran:**
   - **Saldo Bee** (langsung dari saldo)
   - **Bee Pay Later** (jika sudah aktif)

5. **Konfirmasi Transfer**
   - Review detail
   - Tambah catatan (opsional)
   - Klik "Konfirmasi Transfer"

6. **Transfer Berhasil** ✅

---

### 6️⃣ **Aktivasi Pay Later**

> **Note:** Fitur ini membutuhkan eligibility check (akun aktif, KYC verified)

1. **Di Home Screen**, scroll ke bawah

2. **Klik Card "Bee Pay Later"**

3. **Klik "Aktifkan Pay Later"**

4. **Syarat Aktivasi:**
   - ✅ KYC Terverifikasi (otomatis saat registrasi)
   - ✅ Akun Aktif
   - ✅ Tidak Ada Tunggakan

5. **Credit Limit Dihitung Otomatis:**
   - Berdasarkan saldo rata-rata
   - Jumlah transaksi
   - Usia akun
   - Minimum: **Rp 1.000.000**
   - Maximum: **Rp 5.000.000**

6. **Pay Later Aktif** ✅

---

### 7️⃣ **Transfer dengan Pay Later**

1. **Transfer** → Pilih kontak → Masukkan jumlah

2. **Pilih "Bee Pay Later"** sebagai metode pembayaran

3. **Sistem Akan:**
   - Cek limit tersedia
   - Buat loan otomatis
   - Tenor default: **3 bulan**

4. **Installment Info:**
   - **1 bulan:** Bunga 0%
   - **3 bulan:** Bunga 0%
   - **6 bulan:** Bunga 1.5%/bulan
   - **12 bulan:** Bunga 2%/bulan

5. **Minimum Pinjaman:** Rp 10.000

6. **Konfirmasi** → Loan dibuat → Transfer berhasil ✅

---

### 8️⃣ **Cek Transaction History**

1. **Klik "History"** di bottom navigation

2. **Lihat Semua Transaksi:**
   - Top up
   - Transfer
   - Payments
   - Pay Later loans

3. **Filter:**
   - Tanggal
   - Jenis transaksi
   - Status

---

### 9️⃣ **Logout**

1. **Klik icon Profile** (top right)

2. **Scroll ke bawah**

3. **Klik "Logout"**

4. **Konfirmasi Logout**

---

## 📋 Daftar Fitur Lengkap

### ✅ **Fitur yang Sudah Selesai**

#### **Authentication & Security**
- ✅ Registrasi dengan email & phone
- ✅ Login dengan PIN 6 digit
- ✅ Firebase Authentication
- ✅ Auto-login (remember session)
- ✅ Logout

#### **Bank Digital Core**
- ✅ Top Up saldo
- ✅ Transfer ke kontak
- ✅ Manajemen kontak transfer
- ✅ Real-time balance update
- ✅ Transaction history

#### **Pay Later (Phase 1 & 2)**
- ✅ Aktivasi Pay Later
- ✅ Credit limit calculation
- ✅ Eligibility check
- ✅ Transfer dengan Pay Later
- ✅ Loan creation otomatis
- ✅ Installment calculation
- ✅ Real-time limit update
- ✅ Multiple tenor support (1, 3, 6, 12 bulan)

#### **UI/UX**
- ✅ Modern design dengan Bee branding
- ✅ Responsive layout
- ✅ Dark mode ready
- ✅ Loading states
- ✅ Error handling
- ✅ Success animations

#### **Database & Backend**
- ✅ Firestore integration
- ✅ Real-time data sync
- ✅ Transaction persistence
- ✅ User data management
- ✅ Loan records

---

### ⚠️ **Fitur Dalam Pengembangan**

#### **Pay Later Enhancement**
- ⏳ **Tenor Selection UI** - User belum bisa pilih tenor (fixed 3 bulan)
- ⏳ **Installment Info Display** - Preview cicilan di confirmation screen
- ⏳ **Loan History Tab** - Tab riwayat masih empty state
- ⏳ **Loan Detail Screen** - Screen detail per loan
- ⏳ **Pay Installment** - Pembayaran cicilan bulanan
- ⏳ **Overdue Detection** - Deteksi keterlambatan bayar
- ⏳ **Payment Reminder** - Notifikasi jatuh tempo

#### **Bank Digital Enhancement**
- ⏳ **QR Code Payment** - Bayar dengan QR
- ⏳ **Request Money** - Minta uang dari kontak
- ⏳ **Split Bill** - Patungan
- ⏳ **Recurring Payment** - Pembayaran berulang
- ⏳ **Savings Goal** - Target tabungan

#### **Profile & Settings**
- ⏳ **Edit Profile** - Ubah nama, email, phone
- ⏳ **Change PIN** - Ganti PIN keamanan
- ⏳ **KYC Verification** - Upload KTP untuk limit lebih tinggi
- ⏳ **Bank Account Link** - Hubungkan rekening bank
- ⏳ **Notification Settings** - Atur notifikasi

#### **Transaction Features**
- ⏳ **Transaction Search** - Cari transaksi
- ⏳ **Advanced Filters** - Filter berdasarkan kategori, jumlah
- ⏳ **Export Statement** - Download laporan PDF
- ⏳ **Transaction Receipt** - Bukti transfer PDF

#### **Security**
- ⏳ **Biometric Login** - Fingerprint/Face ID
- ⏳ **Two-Factor Authentication** - 2FA via SMS
- ⏳ **Device Authorization** - Kelola perangkat terdaftar

#### **Social Features**
- ⏳ **Invite Friends** - Referral program
- ⏳ **Chat Support** - Customer service
- ⏳ **Ratings & Reviews** - Review merchant

---

### ❌ **Known Issues & Limitations**

1. **Pay Later Activation**
   - Temporary: Eligibility check di-bypass untuk testing
   - Production: Need proper account age & transaction history check

2. **Logo Cache**
   - Perlu uninstall → reinstall untuk refresh app icon
   - Hot reload tidak cukup untuk asset changes

3. **Firestore Index**
   - Warning: Missing composite index for transaction queries
   - Need to create index via Firebase Console

4. **Java Version**
   - Build requires Java 11+ (saat ini pakai Java 17)
   - Gradle 8.13 compatibility

---

## 🛠️ Technical Stack

### **Frontend**
- **Flutter:** 3.6+
- **Dart:** 3.0+
- **State Management:** Provider
- **Routing:** Named routes

### **Backend & Database**
- **Firebase Authentication**
- **Cloud Firestore**
- **Firebase Storage** (untuk KYC docs)

### **Design**
- **Colors:** Orange (#FF9800) & Blue (#6C5CE7)
- **Typography:** Inter, Roboto
- **Icons:** Material Icons
- **Logo:** Custom Bee logo

### **Dependencies**
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  firebase_core: ^2.24.2
  cloud_firestore: ^4.14.0
  firebase_auth: ^4.16.0
  intl: ^0.18.0
```

---

## 📊 Database Structure

### **Users Collection**
```
users/{userId}
├── name: string
├── email: string
├── phone: string
├── pin: string (hashed)
├── balance: number
├── isKycVerified: boolean
├── createdAt: timestamp
└── payLater/
    ├── activation/
    │   ├── status: "active" | "inactive"
    │   ├── creditLimit: number
    │   ├── usedLimit: number
    │   └── availableLimit: number
    └── loans/{loanId}
        ├── amount: number
        ├── tenorMonths: number
        ├── interestRate: number
        ├── monthlyInstallment: number
        ├── totalRepayment: number
        ├── status: "active" | "paid" | "overdue"
        ├── createdAt: timestamp
        └── dueDate: timestamp
```

### **Transactions Collection**
```
transactions/{transactionId}
├── type: "top_up" | "transfer" | "payment"
├── amount: number
├── senderId: string
├── recipientName: string
├── status: "success" | "pending" | "failed"
├── createdAt: timestamp
└── metadata: object
```

---

## 🎨 Design Guidelines

### **Color Palette**
- **Primary:** `#FF9800` (Orange)
- **Secondary:** `#6C5CE7` (Purple/Blue)
- **Success:** `#4CAF50` (Green)
- **Error:** `#F44336` (Red)
- **Text Primary:** `#1E1E1E` (Dark Gray)
- **Text Secondary:** `#757575` (Gray)
- **Background:** `#FFFFFF` (White)
- **Gray Light:** `#F5F5F5`

### **Typography**
- **Heading:** 24-32px, Bold
- **Title:** 18-20px, SemiBold
- **Body:** 14-16px, Regular
- **Caption:** 12-13px, Regular

### **Spacing**
- **XS:** 4px
- **SM:** 8px
- **MD:** 16px
- **LG:** 24px
- **XL:** 32px

---

## 📞 Support & Feedback

**Developer Contact:**
- GitHub: [Your GitHub]
- Email: [Your Email]

**Bug Report:**
Jika menemukan bug, silakan laporkan dengan format:
1. Deskripsi masalah
2. Langkah untuk reproduce
3. Screenshot (jika ada)
4. Device & OS version

---

## 📝 Changelog

### **v1.0.0** (2026-01-06)
- ✅ Initial release
- ✅ Bank Digital core features
- ✅ Pay Later Phase 1 & 2
- ✅ Authentication & security
- ✅ Transaction history
- ✅ Modern UI with Bee branding
- ✅ APK build ready (bee.apk)

---

## 🔐 Security & Privacy

- **Data Encryption:** All sensitive data encrypted
- **PIN Protection:** 6-digit PIN for transactions
- **Firebase Security Rules:** Proper access control
- **No Data Sharing:** User data tidak dibagikan ke pihak ketiga

---

## 📄 License

**Proprietary** - All rights reserved  
© 2026 BEE Bank Digital

---

**Terakhir Diupdate:** 6 Januari 2026  
**Versi Dokumentasi:** 1.0
