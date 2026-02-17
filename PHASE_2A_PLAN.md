# Phase 2a: Outlet Main Screen & Data Fetch – Implementation Plan

> **Goal:** Replace Demo Home with Outlet Main Screen and bottom nav. User sees tabs after login.

---

## Current State

| Item | Status |
|------|--------|
| `prefUserData` | ✅ Exists in PreferencesHelper |
| `prefOutletData` | ✅ Key exists in PreferencesHelper |
| `Outlet` model | ❌ Missing – add from sendme |
| `switchUser` API path | ❌ Missing in api_path.dart |
| Outlet-related GlobalConstants | ❌ Missing – add |
| `apiCall` / HTTP helper | ❌ Missing – add |
| Outlet Main Screen | ❌ Replace Demo Home with it |
| Outlet Account tab | ❌ Simple profile + logout (placeholder for Phase 2a) |

---

## Tasks (in order)

### Task 1: Add Outlet model

**File:** `lib/src/models/outlet.dart` (new)

- Copy from `sendme/lib/src/models/outlet.dart`
- Use `sendme_outlet` package and `flutter_project_imports.dart`
- Fields: `hotelId`, `hotel`, `imageUrl`, `themeId`, `isMedicine`, `currency`, `address`, `outletCountryCode`, `contact`, `cityId`, `userId`, etc.
- Uses `funToInt`, `funToString`, `funToDouble` from app_functions (already in project)
- Import `City` model for `roleAssignCity` (already exists)

---

### Task 2: Add API path and HTTP helper

**File:** `lib/src/api/api_path.dart`

- Add: `static final String switchUser = slsServerPath + 'SwitchUser?';`

**File:** `lib/src/api/api_call.dart` (new) or `lib/src/common/api_helper.dart` (new)

- Add `apiCall(url, param, method, type, context)` that:
  - Uses `http` package for GET/POST
  - Returns `Response`
  - Handles errors (no internet, server error)
- Reference: `sendme/lib/src/api/api_call.dart` and `sendme/lib/src/common/global_constants.dart` (apiCall)

**Alternative:** Implement a simpler `apiCall` directly in GlobalConstants if sendme’s version is heavy.

---

### Task 3: Extend GlobalConstants

**File:** `lib/src/common/global_constants.dart`

Add:

- `static int Outlet = 1;`
- `static int? outletCityId;`
- `static String? outletCountryCode;`
- `static String? outletCurrency;`
- `static int? outletStatus;`
- `static int? themeId;`
- `static int? isMedicine;`
- `static int isOutlet = 0;`
- `static int? AdmincityId;`
- `static int? userType;`
- `static final int Grocery_Store_UI = 3;`
- `static int forceUpdate = 1;`
- `static int? isForceUpdate;`
- `static String? Live_App_Version;`
- `static String? Package_Name;` (from ThemeUI/AppConfig if needed)
- `apiCall` – either as static method or delegate to api_call.dart

---

### Task 4: Implement fetchOutletData

**Logic:** Inside `OutletMainScreen` (or a separate service if preferred)

1. Check internet → if no: navigate to NoInternetConnection (or show error + stay)
2. Read `prefUserData` → parse to get `UserModel u` (mobile, etc.)
3. Build URL: `SwitchUser?userType=1&mobileNumber=${u.mobile}&deviceType=${Device_Type}&version=${App_Version}&deviceId=${Device_Id}`
4. Call `apiCall` (GET)
5. Parse response:
   - `data['Status'] == 1` and `data['Data'] != null`:
     - If `data['Data']['isBlocked'] == 1` → clear prefs (prefUserData, prefOutletData, prefCityData, prefAreaData), navigate to LoginPage(call: 'Block')
     - Else:
       - Set GlobalConstants (outletCityId, outletCountryCode, outletCurrency, outletStatus, themeId, isMedicine, AdmincityId)
       - Save response body to `prefOutletData`
       - Handle force update (if applicable)
       - Return response body
   - Else (fail / no outlet) → show toast with `data["Message"]`, clear prefs, navigate to LoginPage
6. No internet → navigate to NoInternetConnection or show error

**Outlet-only:** On failure, do NOT redirect to UserMainScreen/UserOutletMainScreen. Always logout and go to Login.

---

### Task 5: Create Outlet Main Screen

**File:** `lib/src/ui/outlet/outlet_main_screen.dart` (new)

Structure:

1. StatefulWidget with `tabIndex` (optional) for deep-link
2. State: `_currentIndex`, `outletData` (Future), `UserModel? u`, `_children`
3. `initState`:
   - Set `_currentIndex = widget.tabIndex ?? 0`
   - `outletData = fetchOutletData()`
4. `build`:
   - `WillPopScope` with “Press again to exit”
   - `FutureBuilder` on `outletData`:
     - **loading:** white/loading indicator
     - **error:** error page or toast + redirect to Login
     - **hasData:**
       - Decode JSON → `Outlet.fromJson(data['Data'])`
       - Build `_children` based on theme:
         - Restaurant (`themeId != Grocery_Store_UI` and `isMedicine != 1`): [Home, Orders, Products, Manage, Account]
         - Grocery/Medicine: [Home, Orders, Manage, Account]
       - For Phase 2a, tabs can be placeholders:
         - Home: `OutletHomePage` (Phase 2b) or a simple placeholder
         - Orders: placeholder (“Orders – Coming in Phase 3”)
         - Products: placeholder or `MessageForEmptyPage` for grocery
         - Manage: placeholder
         - Account: `OutletAccountTab` (profile + logout)
5. `BottomNavigationBar` with items matching `_children`
6. `fetchOutletData` method (as above)

---

### Task 6: Create Outlet Account tab

**File:** `lib/src/ui/outlet/outlet_account_tab.dart` (new)

- Display outlet name (from Outlet) and user mobile
- Logout button:
  - Clear `prefUserData`, `prefOutletData`, `prefCityData`, `prefAreaData`
  - `Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginPage(call: 'Main')), (_) => false)`
- No “switch user” or “switch to customer”

---

### Task 7: Placeholder tabs (Phase 2a)

For Home, Orders, Products, Manage (until Phase 2b/3/4/5):

- Use simple `Center(child: Text('Home – Phase 2b'))` style placeholders, or
- Reuse `MessageForEmptyPage` if available (or create a minimal empty-state widget)

---

### Task 8: Update main.dart

**File:** `lib/main.dart`

- In `AuthGate`: if logged in → `OutletMainScreen()` instead of `DemoHomePage()`
- Remove or keep `DemoHomePage` for reference; it will no longer be the post-login route

---

### Task 9: Supporting pieces

1. **NoInternetConnection page** – Create minimal page or reuse from sendme (copy adapted)
2. **MessageForForceUpdate** – Create minimal page if force-update is required (or defer to Phase 6)
3. **MessageForEmptyPage** / **MessageForErrorPage** – Create minimal widgets if needed for empty/error states
4. **Dependencies** – Ensure `http` and `dart:convert` (utf8) are available in pubspec.yaml

---

## File Summary

| Action | File |
|--------|------|
| Create | `lib/src/models/outlet.dart` |
| Modify | `lib/src/api/api_path.dart` (add switchUser) |
| Create | `lib/src/api/api_call.dart` (or api_helper) |
| Modify | `lib/src/common/global_constants.dart` |
| Create | `lib/src/ui/outlet/outlet_main_screen.dart` |
| Create | `lib/src/ui/outlet/outlet_account_tab.dart` |
| Create | `lib/src/ui/outlet/outlet_placeholder_tabs.dart` (optional – simple placeholders) |
| Create | `lib/src/ui/common/no_internet_page.dart` (or similar) |
| Modify | `lib/main.dart` |
| Modify | `lib/flutter_project_imports.dart` (export new files) |

---

## Dependencies

- `http` package (likely already in sendme; check sendme_outlet pubspec)
- `shared_preferences` – already used
- `dart:convert` for `json`, `utf8`

---

## Optional Deferrals

- **Force update:** Can be simplified (e.g. show dialog) or deferred to Phase 6
- **NoInternetConnection:** Can show SnackBar or simple full-screen message for Phase 2a
- **MessageForEmptyPage / MessageForErrorPage:** Use basic `Center` + `Text` until shared widgets exist

---

## Verification

1. Login as outlet user → lands on Outlet Main Screen with bottom nav
2. Tabs switch correctly (Home, Orders, Products/—, Manage, Account)
3. Account → Logout → back to Login
4. If outlet fetch fails (e.g. non-outlet user) → toast + logout → Login
5. If user is blocked → clear prefs + Login with “Block” message
