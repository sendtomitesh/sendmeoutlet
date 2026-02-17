# Phase 2b: Home & Account Tabs – Implementation Plan

> **Goal:** Implement real Home tab (dashboard) and enhance Account tab. Replace placeholders from Phase 2a.

---

## Prerequisites

- Phase 2a complete: `OutletMainScreen`, `Outlet`, `fetchOutletData`, `OutletAccountTab` (basic)

---

## Current State

| Item | Status |
|------|--------|
| Home tab | Placeholder from Phase 2a |
| Account tab | Basic profile + logout from Phase 2a |
| UpdateOutletStatus API | ❌ Add to api_path |
| GetOutletDashboardData API | ❌ Add to api_path |
| GetOrderList API | ❌ Add (for active orders preview) |
| GetHotelDetail API | ❌ Add (for subDomain) |
| GetUserWPOptin API | ❌ Add (WhatsApp opt-in) |
| OutletOrderOrUserOrderDetail model | ❌ Add |
| Reviews model | ❌ Add if needed |

---

## Tasks (in order)

### Task 1: Add API paths

**File:** `lib/src/api/api_path.dart`

Add:

- `updateOutletStatus` – `slsServerPath + 'UpdateOutletStatus?'`
- `getOutletDashBoardData` – `slsServerPath + 'GetOutletDashboardData?'`
- `getOrderList` – `slsServerPath + 'GetOrderList'`
- `getHotelDetail` – `slsServerPath + 'GetHotelDetail?'`
- `getUserWPOpTin` – `slsServerPath + 'GetUserWPOptin?'`

---

### Task 2: Add models

**File:** `lib/src/models/outlet_order_or_user_order_detail.dart` (new)

- Copy from `sendme/lib/src/models/outlet_order_or_user_order_detail.dart`
- Fields: orderId, orderStatus, paymentType, userName, mobile, orderOn, deliveryOn, deliveredAt, riderName, totalBill, currency, slot, etc.
- Adapt imports to `sendme_outlet`

**File:** `lib/src/models/reviews.dart` (new) – if used by outlet home

- Copy from sendme if OutletHomePage uses Reviews

---

### Task 3: Add GlobalConstants for order status

**File:** `lib/src/common/global_constants.dart`

Add order status constants (from sendme):

- `ORDER_PENDING`, `ORDER_DELIVERED`, `HOTEL_ACCEPTED`, `ORDER_PREPARED`, etc.
- `HOME_DELIVERY`, `TAKE_AWAY`

---

### Task 4: Create OutletHomePage

**File:** `lib/src/ui/outlet/outletHome/outlet_home_page.dart` (new)

Reference: `sendme/lib/src/ui/outlet/outletHome/outlet_home_page.dart`

**Structure:**

1. **State:**
   - `outlet` (Outlet), `_outletStatus` (bool), `overViewFilterValue` (Today/Yesterday/This Week/This Month)
   - `totalTodaysOrder`, `totalTodaysNetBill`, `totalDelivered`, `averageRating`, `currency`
   - `loadingData`, `processOverview`, `outletOrder` (List<OutletOrderOrUserOrderDetail>)
   - `subDomain`, `whatsappProcess`
   - `fromDate`, `toDate` (for dashboard date range)
   - `AnimationController` for status toggle and gradient shimmer

2. **APIs to implement:**
   - `fetchOutletDetail()` – GetHotelDetail for subDomain
   - `fetchUserWPOptIn()` – GetUserWPOptin for WhatsApp banner
   - `fetchOutletDashboardData()` – GetOutletDashboardData (fromDate, toDate)
   - `fetchOutletOrders()` – GetOrderList for pending orders preview
   - `changeOutletStatus()` – UpdateOutletStatus

3. **UI sections:**
   - **Header:** Outlet avatar, name, Available/Unavailable, power toggle
   - **Power toggle:** Calls `changeOutletStatus`; when going offline, show bottom sheet “Go online after” (1h, 2h, 4h, tomorrow, manual)
   - **WhatsApp opt-in banner** (if `whatsappProcess == true`)
   - **Overview:** Dropdown (Today, Yesterday, This Week, This Month) → updates fromDate/toDate → `fetchOutletDashboardData`
   - **Stats cards (2x2):** Total Amount, Total Orders, Delivered, Overall Rating
   - **Theme-specific buttons:**
     - Restaurant: Add Order button → `AddOrder` (Phase 6)
     - Grocery/Medicine: Upload Prescription, Upload Items List, Enter Items List → `ManualAddOrderForMedicineAndGrocery` (Phase 6)
   - **Active orders preview:** List of pending orders; tap → `GetOutletOrderDetails` (Phase 3)
   - **Order Prepared** button on accepted orders

4. **Defer to Phase 6:** Add Order, Manual Add Order navigation (can show disabled or “Coming soon” for now)

---

### Task 5: Enhance Outlet Account tab

**File:** `lib/src/ui/outlet/outlet_account_tab.dart` (modify)

- Add outlet image, name, address (from Outlet)
- Add user mobile, name (from UserModel)
- Optional: edit profile (can defer to Phase 6)
- Keep Logout button
- Consider passing `Outlet` and `UserModel` as params

---

### Task 6: Wire OutletMainScreen to real Home

**File:** `lib/src/ui/outlet/outlet_main_screen.dart`

- Replace Home placeholder with `OutletHomePage(outlet: o, index: widget.index)`
- Ensure `userId` (from UserModel) is available for Home if needed (e.g. fetchOutletOrders)

---

### Task 7: Supporting widgets

- **Shimmer / loading:** Use `ListTileShimmer` or simple gradient placeholder (copy from sendme or create minimal)
- **Gradient animation** for loading state (same pattern as sendme outlet_home_page)
- **Bottom sheet** for “Go online after” with radio options

---

## File Summary

| Action | File |
|--------|------|
| Modify | `lib/src/api/api_path.dart` |
| Create | `lib/src/models/outlet_order_or_user_order_detail.dart` |
| Create | `lib/src/models/reviews.dart` (if needed) |
| Modify | `lib/src/common/global_constants.dart` |
| Create | `lib/src/ui/outlet/outletHome/outlet_home_page.dart` |
| Modify | `lib/src/ui/outlet/outlet_account_tab.dart` |
| Modify | `lib/src/ui/outlet/outlet_main_screen.dart` |
| Create | `lib/src/ui/common/list_tile_shimmer.dart` (optional) |

---

## Dependencies

- `intl` for DateFormat
- `image_picker` if Upload Prescription/Items uses camera (Phase 6)
- `rflutter_alert` or similar for bottom sheet (or use `showModalBottomSheet`)

---

## Optional Deferrals

- Add Order / Manual Add Order navigation → Phase 6 (show disabled button or “Coming soon”)
- WhatsApp opt-in banner → Can skip initially if not critical
- Tap on order in Home → navigate to Order Details (Phase 3); can show toast “View in Orders tab” for now

---

## Verification

1. Home tab shows outlet avatar, name, status toggle
2. Toggle Available/Unavailable works and calls UpdateOutletStatus
3. Going offline shows bottom sheet with delay options
4. Overview dropdown loads stats (Total Amount, Orders, Delivered, Rating)
5. Active orders preview shows pending orders (or empty state)
6. Account tab shows outlet + user info, Logout works
