# Bee App - Version History

## v1.0.1 (14 Januari 2026)
**Type:** Bug Fix & UI Improvements

### 🐛 Bug Fixes
- **Fixed Pay Later userId inconsistency** - Changed from phone number to Firebase UID for proper document lookup
- **Fixed updatePayLaterUsage error handling** - Using `.set()` with merge instead of `.update()` to handle missing fields
- **Removed 7-day account age requirement** - Untuk testing purposes, users bisa langsung activate Pay Later

### 🎨 UI Improvements  
- **Removed confusing balance info** from transfer confirmation screen
- **Replaced piggy bank icon** with bee logo di semua screen (splash, welcome, home)
- **Updated welcome screen layout** - Removed duplicate logo, cleaner design

### ✅ Status
- Pay Later: Fully Functional ✅
- Transfer: Working ✅
- Branding: Consistent ✅

---

## v1.0.0 (6 Januari 2026)
**Type:** Initial Release

### ✨ Features
- User registration & Firebase authentication
- Balance management (top-up, transfer)
- KYC verification (selfie + ID card)
- Pay Later activation & usage
- Transaction history
- PIN-based security

### 📦 Technical Stack
- Flutter 3.6+
- Firebase Auth + Firestore
- Provider state management
