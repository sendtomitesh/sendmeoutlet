# Phase 3: Orders Tab – Implementation Plan

> **Goal:** Full Orders tab with sub-tabs (Today, Pending, All, Order Summary), order list, order details, accept/reject/prepared actions.

---

## Prerequisites

- Phase 2a, 2b complete
- `OutletOrderOrUserOrderDetail` model (from Phase 2b)
- `getOrderList` API path (from Phase 2b)
- Order status constants in GlobalConstants

---

## Current State

| Item | Status |
|------|--------|
| Orders tab | Placeholder from Phase 2a |
| GetOrderList API | Added in Phase 2b |
| OutletOrderOrUserOrderDetail model | Added in Phase 2b |
| orderStatusUpdates API | ❌ Add |
| GetOutletOrderDetails / order details | ❌ Implement |

---

## Reference Structure (sendme)

- `outletOrder/outlet_order_tab.dart` – TabController with 4 sub-tabs
- `outletOrder/get_outlet_order_list.dart` – Fetches orders, renders `OutletOrderTabView`
- `outletOrder/outlet_order_tab_view.dart` – List/grid of order cards
- `outletOrder/orderSummary/order_summary_view.dart` – Order Summary tab
- `outletOrder/get_outlet_order_details.dart` – Order detail screen
- `outletOrder/outlet_action_accept_or_cancel_order.dart` – Accept/Reject logic
- `outletOrder/outlet_operations_on_orders.dart` – Order Prepared, etc.

---

## Tasks (in order)

### Task 1: Add API paths

**File:** `lib/src/api/api_path.dart`

Add:

- `orderStatusUpdates` – `slsServerPath + 'OrderStatusUpdates?'`

---

### Task 2: Create OutletOrderTab

**File:** `lib/src/ui/outlet/outletOrder/outlet_order_tab.dart` (new)

Reference: `sendme/lib/src/ui/outlet/outletOrder/outlet_order_tab.dart`

**Structure:**

- StatefulWidget with `outlet`, `userId`, `index` (optional)
- TabController: length 4 (or 3 for Lebanon/Talabetak if `activeApp.id` check)
- Sub-tabs: Today Order, Pending, All Order, Order Summary
- AppBar: outlet name, refresh icon
- TabBarView children:
  - `GetOutletOrderList(tab: 1, outlet, userId)` – Today
  - `GetOutletOrderList(tab: 2, outlet, userId)` – Pending
  - `GetOutletOrderList(tab: 3, outlet, userId)` – All
  - `OrderSummaryView(outlet)` – Order Summary
- Refresh: `Navigator.pushReplacement(OutletMainScreen(tabIndex: 1, index: _controller.index))`
- Optional: `GlobalConstants.streamController` for `outletNotify` (if used)

---

### Task 3: Create GetOutletOrderList

**File:** `lib/src/ui/outlet/outletOrder/get_outlet_order_list.dart` (new)

Reference: `sendme/lib/src/ui/outlet/outletOrder/get_outlet_order_list.dart`

**Logic:**

- `tab: 1` → Today (dateType=2)
- `tab: 2` → Pending (type=ORDER_PENDING)
- `tab: 3` → All (dateType=1)
- API: `GetOrderList` POST with params: outletId, pageIndex, pagination, type, dateType, fromDate, toDate, userType, CountryCode, deliveryPartnerId, deviceType, version, deviceId
- Parse `data['Data']` → `List<OutletOrderOrUserOrderDetail>`
- Pass to `OutletOrderTabView` for list rendering
- Loading: `SpinKitThreeBounce` or `CircularProgressIndicator`
- Error: `MessageForErrorPage`
- Empty: `MessageForEmptyPage`

---

### Task 4: Create OutletOrderTabView

**File:** `lib/src/ui/outlet/outletOrder/outlet_order_tab_view.dart` (new)

Reference: `sendme/lib/src/ui/outlet/outletOrder/outlet_order_tab_view.dart`

- Receives `outletOrder` (List), `userId`, `page`, `pagination`, `tab`
- Renders list of order cards
- Each card: orderId, status, customer name, phone, order time, delivery time, rider, total bill
- Color by status: Pending=red, Cancelled=grey, Accepted/Prepared/Delivered=white/green
- Tap card → `GetOutletOrderDetails(order: outletOrder[index])`
- Order Prepared button for accepted orders
- Pagination if needed (load more)
- Empty state when no orders

---

### Task 5: Create GetOutletOrderDetails

**File:** `lib/src/ui/outlet/outletOrder/get_outlet_order_details.dart` (new)

Reference: `sendme/lib/src/ui/outlet/outletOrder/get_outlet_order_detail.dart` (note: naming may vary)

- Full order detail: items, amounts, addresses, customer, delivery info
- Accept / Reject buttons (for pending)
- Order Prepared button (for accepted)
- Uses `OutletActionAcceptOrCancelOrder`, `OutletOperationsOnOrders` or inline logic
- API: `OrderStatusUpdates` for accept/reject/prepared

---

### Task 6: Create OrderSummaryView

**File:** `lib/src/ui/outlet/outletOrder/orderSummary/order_summary_view.dart` (new)

Reference: `sendme/lib/src/ui/outlet/outletOrder/orderSummary/order_summary_view.dart`

- Aggregated view of orders (date range, totals)
- API: likely `GetOrderList` or specific summary API
- Copy structure from sendme

---

### Task 7: Accept / Reject / Order Prepared logic

**Files:** Can be inline in `GetOutletOrderDetails` or separate:

- `outlet_action_accept_or_cancel_order.dart` – Accept/Reject
- `outlet_operations_on_orders.dart` – Order Prepared

**APIs:**

- `OrderStatusUpdates?orderId=...&reason=...&userId=...&orderStatus=...&actionType=...&userType=...&deviceType=...&version=...&deviceId=...`

---

### Task 8: Wire OutletMainScreen

**File:** `lib/src/ui/outlet/outlet_main_screen.dart`

- Replace Orders placeholder with `OutletOrderTab(outlet: o, userId: u!.userId, index: widget.index)`

---

## File Summary

| Action | File |
|--------|------|
| Modify | `lib/src/api/api_path.dart` |
| Create | `lib/src/ui/outlet/outletOrder/outlet_order_tab.dart` |
| Create | `lib/src/ui/outlet/outletOrder/get_outlet_order_list.dart` |
| Create | `lib/src/ui/outlet/outletOrder/outlet_order_tab_view.dart` |
| Create | `lib/src/ui/outlet/outletOrder/get_outlet_order_details.dart` |
| Create | `lib/src/ui/outlet/outletOrder/orderSummary/order_summary_view.dart` |
| Create | `lib/src/ui/outlet/outletOrder/outlet_action_accept_or_cancel_order.dart` (or inline) |
| Create | `lib/src/ui/outlet/outletOrder/outlet_operations_on_orders.dart` (or inline) |
| Modify | `lib/src/ui/outlet/outlet_main_screen.dart` |

---

## Dependencies

- `flutter_spinkit` or similar for loading (or use built-in)
- `intl` for date formatting

---

## Flavor-specific behavior

- Lebanon / Talabetak: hide Order Summary tab (3 tabs only)
- Use `activeApp.id` from AppConfig

---

## Verification

1. Orders tab shows sub-tabs: Today, Pending, All, Order Summary
2. Each sub-tab loads orders from API
3. Order cards display correctly
4. Tap order → Order Details screen
5. Accept / Reject works for pending orders
6. Order Prepared works for accepted orders
7. Refresh updates list
8. Empty state when no orders
