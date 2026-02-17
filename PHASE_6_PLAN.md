# Phase 6: Extras & Polish – Implementation Plan

> **Goal:** Add remaining flows (Add Order, Order Details, Manual Add for grocery/medicine, WebStore Link, time slots), fix gaps, polish UX, localization, error handling.

---

## Prerequisites

- Phases 2a, 2b, 3, 4, 5 complete
- Core outlet flow working end-to-end

---

## Scope

Phase 6 covers items that were deferred or are cross-cutting:

1. **Add Order flow** – Manual order creation for restaurant
2. **Manual Add Order** – Grocery/Medicine (prescription upload, items list)
3. **Order Details** – Enhancements if any gaps from Phase 3
4. **Generate WebStore Link** – Share outlet webstore
5. **Time slots** – May be in Phase 5 Profile; ensure complete
6. **Force update** – Full implementation if deferred
7. **No Internet / Error pages** – Polish
8. **Localization** – Add missing strings
9. **Assets** – Missing icons, images
10. **Bug fixes & UX polish**

---

## Tasks (grouped by area)

### Area 1: Add Order (Restaurant)

**Reference:** `sendme/lib/src/ui/outlet/outletOrder/add_order.dart`

**File:** `lib/src/ui/outlet/outletOrder/add_order.dart` (new)

- Manual order creation: select customer, items, address
- Uses `AddOrder` API or `createOrder`-like flow
- May need:
  - `add_customer_detail.dart` – Customer search/select
  - `add_cutomer_name_and_no.dart` – Manual customer entry
  - `outletCatlog/outlet_details_and_menu_view.dart` – Menu/catalog for item selection
  - `manual_cart_view.dart` – Cart
- APIs: `getUserFromMobileNumber`, `getAddressListByUserId`, `addOrder` or equivalent
- Navigate from Home "Add Order" button

---

### Area 2: Manual Add Order (Grocery/Medicine)

**Reference:** `sendme/lib/src/ui/outlet/outletOrder/manual_add_order_for_medicine_and_grocery.dart`

**File:** `lib/src/ui/outlet/outletOrder/manual_add_order_for_medicine_and_grocery.dart` (new)

- Two modes: Upload image (prescription/items list) OR Enter items manually
- Image: `image_picker` for camera/gallery, upload via API
- Manual: Form to enter items
- APIs: `uploadPresImage`, order creation APIs
- Navigate from Home "Upload Prescription" / "Enter Items List" buttons

---

### Area 3: Generate WebStore Link

**Reference:** `sendme/lib/src/ui/outlet/outletHome/genrate_webstore_link_view.dart`

**File:** `lib/src/ui/outlet/outletHome/genrate_webstore_link_view.dart` (new)

- API: `getOutletWebStoreLink` or `GetOutletWebStoreLink`
- Show subdomain / link, share button
- May be embedded in Home or Profile
- `share_plus` for sharing

---

### Area 4: Time Slots (if not complete in Phase 5)

- `addTimeSlotsToOutlet` – POST
- `getTimeSlotsByOutletId` – GET
- `OutletTimeSlotsView`, `OutletAddAndEditTimeFormView`
- Ensure full CRUD

---

### Area 5: Force Update

**File:** `lib/src/ui/common/message_for_force_update.dart` (new)

- Full-screen or dialog: "Update required"
- Link to Play Store / App Store
- Logic in `fetchOutletData`: compare `Live_App_Version` with `App_Version`, navigate if update required

---

### Area 6: No Internet & Error Pages

**Files:**

- `lib/src/ui/common/no_internet_page.dart` – Retry button, message
- `lib/src/ui/common/message_for_empty_page.dart` – No data state
- `lib/src/ui/common/message_for_error_page.dart` – Error with retry

Ensure used consistently across all API calls.

---

### Area 7: Localization

- Add missing strings to localization files
- Keys used: `TodayOrder`, `Pending`, `AllOrder`, `OrderSummary`, `ManageStore`, `Catalogue`, `Available`, `Unavailable`, `TotalAmount`, `TotalOrders`, `Delivered`, `OverallRating`, `AddOrder`, `UploadPrescription`, `EnterItemsList`, etc.
- Reference sendme `AppLocalizations` / l10n files

---

### Area 8: Assets

- Ensure all `AssetsImage.*` and `AssetsFont.*` used in outlet screens exist
- Add placeholder images if needed (noData, something_wrong, etc.)
- Icons for bottom nav, manage menu, etc.

---

### Area 9: AppConfig / Flavor checks

- `activeApp.id` for Lebanon, Talabetak, etc.
- Hide/show features per flavor
- Ensure `AppConfig.dart` is complete for all flavors

---

### Area 10: Testing & Polish

- Test full flow: Login → Home → Orders → Products → Manage → Account
- Test Add Order, Manual Add Order
- Test Accept/Reject/Prepared
- Test offline behavior
- Fix any crashes, layout issues
- Ensure back navigation is correct
- Double-tap back to exit (already in OutletMainScreen)

---

## File Summary (Phase 6)

| Action | File |
|--------|------|
| Create | `lib/src/ui/outlet/outletOrder/add_order.dart` |
| Create | `lib/src/ui/outlet/outletOrder/add_customer_detail.dart` |
| Create | `lib/src/ui/outlet/outletOrder/add_cutomer_name_and_no.dart` |
| Create | `lib/src/ui/outlet/outletOrder/manual_add_order_for_medicine_and_grocery.dart` |
| Create | `lib/src/ui/outlet/outletOrder/outletCatlog/outlet_details_and_menu_view.dart` |
| Create | `lib/src/ui/outlet/outletOrder/manual_cart_view.dart` |
| Create | `lib/src/ui/outlet/outletHome/genrate_webstore_link_view.dart` |
| Create | `lib/src/ui/common/message_for_force_update.dart` |
| Enhance | `lib/src/ui/common/no_internet_page.dart` |
| Enhance | `lib/src/ui/common/message_for_empty_page.dart` |
| Enhance | `lib/src/ui/common/message_for_error_page.dart` |
| Add | Localization strings |
| Add | Missing assets |
| Modify | Various (fixes, polish) |

---

## Dependencies

- `image_picker` – Upload prescription/items image
- `share_plus` – Share webstore link
- `url_launcher` – Open store links for force update
- `intl` – Date/number formatting

---

## Priority Order

1. Add Order (restaurant) – high impact
2. Manual Add Order (grocery/medicine) – for those themes
3. Generate WebStore Link – medium
4. Force Update – if required by backend
5. No Internet / Error pages – UX
6. Localization – UX
7. Assets – UX
8. Bug fixes & polish – ongoing

---

## Verification

1. Add Order creates order successfully
2. Manual Add Order (image + manual) works for grocery/medicine
3. WebStore link generates and shares
4. Force update triggers when backend mandates
5. No internet shows proper screen
6. All critical strings localized
7. No crashes in happy path and error paths
