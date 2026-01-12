# Tính năng phát nhạc tự động - Implementation Summary

## ✅ Đã hoàn thành

### 1. Dependencies
- ✅ Thêm `audioplayers: ^5.2.1` package
- ✅ Thêm `shared_preferences: ^2.2.2` package
- ✅ Setup assets folder: `assets/sounds/`
- ✅ Chạy `flutter pub get`

### 2. MusicProvider
- ✅ Tạo `lib/providers/music_provider.dart`
- ✅ Quản lý state: isPlaying, isMusicEnabled, isLoading
- ✅ Methods: play(), pause(), stop(), resume(), toggleMusicEnabled()
- ✅ Lưu user preference vào SharedPreferences
- ✅ Auto-loop nhạc khi đang phát

### 3. Timer Integration
- ✅ Tích hợp MusicProvider vào TimerProvider
- ✅ Tự động phát nhạc khi start session
- ✅ Tự động pause nhạc khi pause timer
- ✅ Tự động resume nhạc khi resume timer
- ✅ Tự động stop nhạc khi complete/cancel session

### 4. UI Update
- ✅ Thêm toggle button trong DeepFocusScreen AppBar
- ✅ Icon động: volume_up (enabled) / volume_off (disabled)
- ✅ Tooltip hướng dẫn
- ✅ SnackBar thông báo khi toggle

### 5. Constants
- ✅ Thêm constants vào `app_constants.dart`:
  - `focusMusicPath`: Path đến file nhạc
  - `musicEnabledKey`: Key lưu preference
  - `defaultMusicVolume`: Volume mặc định (0.5)

## 📝 Cần làm thêm

### **QUAN TRỌNG**: Thêm file nhạc

Bạn cần thêm file nhạc vào thư mục `assets/sounds/` với tên:
- **`focus_music.mp3`** (hoặc .wav, .m4a)

#### Gợi ý loại nhạc:
- Lo-fi music (phổ biến cho focus)
- Ambient/chill music
- White noise / nature sounds
- Study/concentration music

#### Nguồn tải nhạc miễn phí:
- YouTube Audio Library
- Free Music Archive
- Pixabay Music
- Incompetech
- Bensound

#### Yêu cầu file:
- Format: MP3, WAV, hoặc M4A
- Độ dài: 2-10 phút (sẽ tự động loop)
- Volume: Vừa phải (có thể điều chỉnh trong code nếu cần)

## 🎵 Cách sử dụng

1. **Mặc định**: Nhạc được bật (isMusicEnabled = true)
2. **Khi start session**: Nhạc tự động phát (nếu enabled)
3. **Toggle music**: Tap vào icon volume trong AppBar
4. **Preference được lưu**: App sẽ nhớ setting của bạn

## 🔧 Tùy chỉnh (nếu cần)

### Thay đổi tên file nhạc
Sửa trong `lib/core/constants/app_constants.dart`:
```dart
static const String focusMusicPath = 'assets/sounds/your_music_file.mp3';
```

### Thay đổi volume mặc định
Sửa trong `lib/core/constants/app_constants.dart`:
```dart
static const double defaultMusicVolume = 0.7; // 0.0 - 1.0
```

### Thêm nhiều bài nhạc
Để thêm tính năng chọn bài nhạc:
1. Thêm danh sách nhạc vào constants
2. Thêm method selectMusic() vào MusicProvider
3. Thêm UI để chọn nhạc trong Settings

## 📱 Test

1. Thêm file nhạc vào `assets/sounds/focus_music.mp3`
2. Chạy app: `flutter run`
3. Vào Deep Focus screen
4. Tap Start Session → Nhạc sẽ phát
5. Tap Pause → Nhạc sẽ pause
6. Tap Resume → Nhạc sẽ tiếp tục
7. Tap icon volume → Toggle on/off music
8. Restart app → Setting được lưu

## 🐛 Troubleshooting

### Nhạc không phát
- Kiểm tra file nhạc đã có trong `assets/sounds/`
- Kiểm tra tên file đúng: `focus_music.mp3`
- Kiểm tra pubspec.yaml đã include `assets/sounds/`
- Chạy `flutter clean && flutter pub get`

### Nhạc bị lag/giật
- Giảm kích thước file nhạc (nên < 5MB)
- Dùng format MP3 thay vì WAV
- Kiểm tra bitrate (nên dùng 128kbps - 192kbps)

### Error khi build
- Chạy `flutter pub get` lại
- Clean build: `flutter clean`
- Restart IDE/Editor

## Files đã thay đổi

1. `pubspec.yaml` - Dependencies và assets
2. `lib/core/constants/app_constants.dart` - Constants
3. `lib/providers/music_provider.dart` - NEW FILE
4. `lib/providers/timer_provider.dart` - Integration
5. `lib/screens/home/deep_focus_screen.dart` - UI toggle button
6. `assets/sounds/README.md` - Hướng dẫn

