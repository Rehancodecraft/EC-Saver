# 🔄 Database Migration Guide - v1.1.0

## ✅ How Database Migration Works

When users update from **v1.0.9** to **v1.1.0**, the database automatically migrates:

### Automatic Migration Process

1. **User installs v1.1.0 APK** (updates from v1.0.9)
2. **App opens** and initializes database
3. **SQLite detects version change**: 
   - Old database: version 1
   - New code: version 2
4. **`onUpgrade` is called automatically**
5. **`off_days` table is created**
6. **Migration complete** - user can now use off days feature

### Migration Code

```dart
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    // Add off_days table for version 2
    await db.execute('''
      CREATE TABLE IF NOT EXISTS off_days(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        off_date TEXT NOT NULL UNIQUE,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }
}
```

## 🔍 Troubleshooting

### If Off Days Feature Doesn't Work After Update

1. **Check Database Version**:
   - The database should be at version 2
   - Check logs for: `DEBUG: Database upgrade from version 1 to 2`

2. **Verify Table Exists**:
   - The `off_days` table should be created
   - Check logs for: `DEBUG: Successfully created off_days table`

3. **Manual Verification**:
   - Open the app
   - Go to "Off Days" screen
   - If it works, migration was successful
   - If it crashes, check logs for errors

### Common Issues

**Issue**: Off days feature not available after update
- **Cause**: Migration didn't run
- **Solution**: Uninstall and reinstall the app (data will be lost, but migration will work)

**Issue**: App crashes when opening Off Days screen
- **Cause**: Table not created properly
- **Solution**: Check logs for migration errors

## 📋 Migration Verification

After updating to v1.1.0, verify migration:

1. ✅ App opens without errors
2. ✅ "Off Days" menu item appears in drawer
3. ✅ Can open "Off Days" screen
4. ✅ Can add off days
5. ✅ Off days appear in records screen

## 🛡️ Data Safety

**All existing data is preserved:**
- ✅ User profile
- ✅ Emergency records
- ✅ Monthly statistics
- ✅ Feedback
- ✅ Settings

**New data added:**
- ✅ `off_days` table (empty initially)

---

**Note**: The migration runs automatically when the app is opened after updating. No user action required!

