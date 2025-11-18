# Emergency Cases Saver - Rescue 1122 Punjab

## Project Overview
Flutter mobile application for Rescue 1122 Punjab emergency services personnel. Enables offline emergency incident tracking and management across all 36 districts of Punjab, Pakistan.

## Critical Project Constraints

### Technical Requirements
- **100% Offline Operation**: All data stored locally in SQLite, no cloud/internet dependency
- **Target Users**: Rescue 1122 field operators in Punjab, Pakistan
- **Platform Priority**: Android primary, Linux/Web for testing only
- **Flutter Version**: 3.38.1 or higher
- **Minimum Android SDK**: API 21 (Android 5.0)
- **Database**: SQLite with sqflite package

### Build Requirements
**Linux Desktop Testing** requires:
```bash
clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
```

**Android APK Building** requires:
- Android Studio installed
- Gradle version 8.7.3 or higher (not 7.x)
- Android SDK API 34

## Design System & Branding

### Color Palette (Rescue 1122 Theme)
- Primary Red: `#D32F2F` - Emergency alerts, primary actions
- Secondary Green: `#388E3C` - Success states, medical theme
- Background: `#FFFFFF` - Clean white
- Text Dark: `#212121` - Primary text
- Text Light: `#757575` - Secondary text
- Error Red: `#F44336` - Validation errors
- Success Green: `#4CAF50` - Success messages

### Emergency Type Colors
- Bike/Car Accident: `#FF9800` (Orange) / `#2196F3` (Blue)
- Fire Emergency: `#D32F2F` (Red)
- Other Emergency: `#9E9E9E` (Grey)

### UI Standards
- Material Design 3 components
- Border radius: 8-12px standard
- Spacing: 16dp standard padding/margin
- Elevation: 2-8dp for cards/buttons
- No custom fonts - use system default (removed Roboto references)
- App bar height: standard with proper safe area padding
- Drawer width: Keep narrow (not full width)

## Data Patterns

### User Designations (EXACT LIST - DO NOT MODIFY)
```dart
['LTV', 'FDR', 'JCO', 'S.I', 'SC', 'RSO']
```
**IMPORTANT**: These are official Rescue 1122 designations. Never add generic terms like "Rescue Officer" or "Other".

### Districts & Tehsils
- 36 Punjab districts supported
- 150+ tehsils dynamically loaded based on district selection
- Data stored in `lib/utils/districts_data.dart`
- Never hardcode district/tehsil lists in UI components

### Emergency Data
- **EC Number**: Exactly 6 digits, unique, auto-increment suggested
- **Date**: DATE ONLY (no time field) - use DatePicker without TimePicker
- **Emergency Types**: Bike Accident, Car Accident, Fire Emergency, Other Emergency
- **Location**: Optional, max 200 characters
- **Notes**: Optional, max 500 characters
- **Late Entry Detection**: Automatic based on date comparison

### Demo/Test Data
- **OTP for Testing**: Always `123456` (6 digits)
- **Test EC Number**: `000001`
- **Test Mobile**: `03001234567` (Pakistan format)

## Architecture Patterns

### File Structure
```
lib/
├── main.dart              # Entry point, theme configuration
├── models/                # Data models only
│   ├── user_profile.dart
│   ├── emergency.dart
│   └── monthly_stats.dart
├── screens/               # Full-page screens
├── widgets/               # Reusable components
├── services/              # Business logic, API calls
│   └── database_service.dart
└── utils/                 # Constants, helpers, data
    ├── constants.dart
    └── districts_data.dart
```

### Database Service Pattern
- Single `DatabaseService` class with singleton pattern
- All CRUD operations in one service file
- Methods return `Future<T>` for async operations
- Use transactions for multi-step operations
- Indexed columns: `ec_number`, `date_time` for performance

### State Management
- Provider pattern for state management
- Keep state close to where it's used
- Avoid global state when possible
- Rebuild only necessary widgets

## Known Issues & Solutions

### Build/Configuration Issues

**Issue**: "No Linux desktop project configured"  
**Solution**: Run `flutter create --platforms=linux,web .`

**Issue**: "Android Gradle Plugin version X is lower than Y"  
**Solution**: Update `android/build.gradle` and `android/settings.gradle` to Gradle 8.7.3+

**Issue**: "Unable to locate asset: fonts/Roboto-Regular.ttf"  
**Solution**: Remove fonts section from `pubspec.yaml` (use system fonts)

**Issue**: "Could not find compiler set in environment variable CXX: clang++"  
**Solution**: Install build tools: `sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev`

### UI/UX Fixes Needed

**Emergency Type Cards**:
- Must be clickable (not just visual)
- On tap: Navigate to EmergencyFormScreen with type pre-selected
- Use InkWell or GestureDetector for tap handling

**App Bar Text**:
- Avoid overlapping with logo
- Use proper Row spacing
- Consider responsive sizing for long text

**Drawer Menu**:
- Keep width around 280-300dp (not full screen)
- Limit header height
- Use ListView.builder for menu items

**Records Display**:
- Show in list/table format (not just cards)
- Consider DataTable or custom row widgets
- Group by month with clear headers
- Sortable columns if using DataTable

**WhatsApp Integration**:
- Use `url_launcher` package correctly
- Format: `https://wa.me/<phone>?text=<message>`
- Phone format: Remove spaces/dashes, include country code
- Handle launch failures gracefully

**PDF Generation**:
- Use `pdf` and `printing` packages
- Generate monthly reports with Rescue 1122 header
- Include logo as watermark
- Format: Table with EC#, Date, Type, Location
- Allow month selection before generation

## Date Handling

**CRITICAL**: Emergency date field should be DATE ONLY, no time selection.

### Implementation Pattern
```dart
// CORRECT: Date only picker
DateTime _selectedDate = DateTime.now();

Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: _selectedDate,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
  );
  if (picked != null) {
    setState(() {
      _selectedDate = picked;
    });
  }
}

// Display format: DD-MM-YYYY only
String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
}
```

### Storage Format
- Store as ISO 8601 string in SQLite: `date.toIso8601String()`
- Parse on retrieval: `DateTime.parse(storedString)`
- Display in DD-MM-YYYY format for users

## Testing Strategy

### Quick Testing (No Android SDK)
1. **Web Browser**: `flutter run -d chrome` (instant, no build tools needed)
2. **Linux Desktop**: `flutter run -d linux` (requires build tools, best for full testing)

### Production Testing
1. Build APK: `flutter build apk --release`
2. Install on real Android device
3. Test all features offline
4. Verify database persistence across app restarts

### Test Checklist
- [ ] Registration with all 6 designations
- [ ] OTP verification (123456)
- [ ] Emergency entry with date only
- [ ] EC number auto-increment
- [ ] Duplicate EC number prevention
- [ ] Search by EC number, location
- [ ] Filter by emergency type
- [ ] Month-wise grouping
- [ ] Monthly PDF generation
- [ ] WhatsApp contact opens correctly
- [ ] Offline functionality (airplane mode test)

## Performance Requirements
- App launch: < 2 seconds
- Database queries: < 100ms for standard operations
- Scroll performance: 60 FPS minimum
- First build: 2-3 minutes (expected)
- Subsequent builds: 10-30 seconds
- Hot reload: < 1 second

## Security & Privacy
- No external API calls
- No analytics or tracking
- All data stored locally on device
- No cloud backup (by design)
- User profile stored once, never transmitted

## Documentation Standards
- Every screen has header comment explaining purpose
- Database methods documented with parameters and return types
- Complex business logic has inline comments
- README files for setup, building, API reference

## Deployment Process
1. Test thoroughly on Linux/Web
2. Install Android Studio and SDK
3. Update version in pubspec.yaml
4. Build release APK: `flutter build apk --release`
5. Test on real device
6. Sign APK for production (if distributing via Play Store)
7. Distribute to Rescue 1122 personnel

## Important Files Locations
- Logo: `assets/images/logo.png` (145KB, must exist)
- Districts data: `lib/utils/districts_data.dart`
- Database service: `lib/services/database_service.dart`
- App constants: `lib/utils/constants.dart`
- Android config: `android/app/build.gradle`
- Main theme: `lib/main.dart`

## Contact & Support
- Developer: NexiVault Tech Solutions
- WhatsApp: +92 324 4266595
- Target Organization: Rescue 1122 Punjab, Pakistan

## Current Known TODOs
1. Fix emergency type card click handlers
2. Implement PDF generation for monthly reports
3. Fix WhatsApp launch URL
4. Convert records to table/list view
5. Adjust drawer dimensions
6. Remove time picker, keep date only
7. Fix app bar text overlap with logo
8. Add month selector for PDF export