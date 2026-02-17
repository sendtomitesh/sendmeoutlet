# Phase 5: Manage Tab – Implementation Plan

> **Goal:** Full Manage tab with dynamic menu from `GetStoreMenuTab` API. Navigate to Offers, Coupons, Reviews, Reports, Riders, Profile, Delivery Area, WhatsApp Stories.

---

## Prerequisites

- Phase 2a, 2b, 3 complete
- Phase 4 optional (Manage is independent)

---

## Current State

| Item | Status |
|------|--------|
| Manage tab | Placeholder from Phase 2a |
| GetStoreMenuTab API | ❌ Add |
| ManageOutletStore model | ❌ Add |
| Child screens (Offers, Coupons, etc.) | ❌ All to be created |

---

## Reference Structure (sendme)

- `outletManage/outlet_manage_view.dart` – Fetches menu, renders list
- `ManageOutletStore` model: id, name, isBlocked
- API: `GetStoreMenuTab?outletId=...&userType=...&deviceType=...&version=...&deviceId=...`
- Menu IDs map to screens: 1=Offers, 2=Coupons, 3=Reviews, 4=BillReports, 5=Riders, 6=Profile, 7=DeliveryArea, 8=WhatsAppStories
- Flavor-specific hiding: Lebanon hides 7, 8, 5, 2; Talabetak hides 8, 2

---

## Tasks (in order)

### Task 1: Add API paths

**File:** `lib/src/api/api_path.dart`

Add:

- `getStoreMenuTab` – `slsServerPath + 'GetStoreMenuTab?'`

Also add APIs needed by each child screen (can be done incrementally as each screen is built):

- Offers: `getOfferList`
- Coupons: coupon-related APIs
- Reviews: `getOutletRatingAndReviews`, `replayToReviewsByOutlet`
- Reports: `getTotalBillAmountForReports` or similar
- Riders: `getMyRiders`, `addDeliveryPartnerToOutlet`, etc.
- Profile: `manageOutletDetail`, `getTimeSlotsByOutletId`, `saveHolidayForOutlet`
- Delivery Area: `getOutletAreaByOutletId`, area management APIs
- WhatsApp: `getWhatsAppGraphicsCategory`, `getWhatsAppGraphics`, `setWhatsAppGraphics`

---

### Task 2: Add ManageOutletStore model

**File:** `lib/src/models/manage_outlet_store.dart` (new)

Copy from `sendme/lib/src/models/manage_outlet_store.dart`

- Fields: `id`, `name`, `isBlocked`
- `fromJson`

---

### Task 3: Create OutletManageView

**File:** `lib/src/ui/outlet/outletManage/outlet_manage_view.dart` (new)

Reference: `sendme/lib/src/ui/outlet/outletManage/outlet_manage_view.dart`

**Structure:**

- Fetch `GetStoreMenuTab` in initState
- Parse `data['Data']` → `List<ManageOutletStore>`
- Loading: shimmer list
- ListView of items; each item shows icon + name
- `getManageListIconById(id)` – map id to asset path
- On tap: switch on `manageStoreList[index].id`:
  - 1 → `OutletOffersView(outlet)`
  - 2 → `OutletCouponsView(outlet)`
  - 3 → `OutletReviewsView(outlet, userId)`
  - 4 → `OutletBillReports(outlet)`
  - 5 → `OutletRiderListView(outlet)`
  - 6 → `OutletProfileView(outlet)`
  - 7 → `OutletDeliveryAreaAndCharges(outlet)`
  - 8 → `OutletWhatsappStoriesView(outlet)`
- Visibility: hide if `isBlocked == 1` or flavor-specific (e.g. `activeApp.id == 'send_me_lebanon'` and id in [7,8,5,2])
- Assets: Add icons for offers, coupons, reviews, report, riders, profile, delivery, whatsapp

---

### Task 4: Create child screens (one by one)

**Order of implementation (by priority):**

1. **OutletProfileView** – Most critical: outlet info, time slots, holidays
2. **OutletOffersView** – List/add/edit offers
3. **OutletCouponsView** – List/add/edit coupons
4. **OutletReviewsView** – View and reply to reviews
5. **OutletBillReports** – Reports / analytics
6. **OutletDeliveryAreaAndCharges** – Delivery areas and charges
7. **OutletRiderListView** – Riders management
8. **OutletWhatsappStoriesView** – WhatsApp graphics/stories

Each screen: copy from sendme, adapt imports, remove user-app dependencies.

---

### Task 5: OutletProfileView

**File:** `lib/src/ui/outlet/outletManage/outlet_profile/outlet_profile_view.dart`

- Outlet details (name, address, contact, image)
- Time slots: `OutletTimeSlotsView` – add/edit/delete slots
- Holidays: `OutletHolidayView` – add holidays
- APIs: `manageOutletDetail`, `getTimeSlotsByOutletId`, `addTimeSlotsToOutlet`, `saveHolidayForOutlet`, `getHolidayForOutlet`

---

### Task 6: OutletOffersView

**File:** `lib/src/ui/outlet/outletManage/outlet_offers/outlet_offers_view.dart`

- List offers from `getOfferList`
- Add/Edit: `OutletAddAndEditOfferFormView`, `OutletAddAndEditOffer`
- API: `manageOffer`, `getOfferList`

---

### Task 7: OutletCouponsView

**File:** `lib/src/ui/outlet/outletManage/outlet_coupons/outlet_coupons_view.dart`

- List coupons
- Add/Edit: `OutletAddAndEditCouponFormView`, `OutletAddAndEditCoupon`
- API: `manageCoupon`, `getCouponsList` (from Admin APIs)

---

### Task 8: OutletReviewsView

**File:** `lib/src/ui/outlet/outletManage/outlet_reviews/outlet_reviews_view.dart`

- List reviews from `getOutletRatingAndReviews`
- Reply: `OutletReviewReplyAlertView`, `replayToReviewsByOutlet`

---

### Task 9: OutletBillReports

**File:** `lib/src/ui/outlet/outletManage/outlet_reports/outlet_reports.dart` + `outlet_reports_view.dart`

- Date range picker
- Fetch `getTotalBillAmountForReports` or report APIs
- Display tables/charts

---

### Task 10: OutletDeliveryAreaAndCharges

**File:** `lib/src/ui/outlet/outletManage/outlet_delivery_area_and_charges/outlet_delivery_area_and_charges_view.dart`

- List areas from `getOutletAreaByOutletId`
- Add/Edit area: `OutletAddAndEditDeliveryAreaFormView`
- Area management APIs

---

### Task 11: OutletRiderListView

**File:** `lib/src/ui/outlet/outletManage/outlet_rider/outlet_rider_list_view.dart`

- List riders from `getMyRiders`
- Add/Edit: `OutletAddAndEditRiderFormView`
- API: `addDeliveryPartnerToOutlet`, rider management

---

### Task 12: OutletWhatsappStoriesView

**File:** `lib/src/ui/outlet/outletManage/outlet_whatsapp_stories/outlet_whatsapp_stories_view.dart`

- Categories from `getWhatsAppGraphicsCategory`
- Graphics from `getWhatsAppGraphics`
- Set: `setWhatsAppGraphics`
- Template view if needed

---

### Task 13: Add assets

**File:** `lib/src/common/assets_path.dart` (or assets)

- Add icon paths: offers, coupons, reviews, report, riders, outletProfile, deliveryCharges, whatsappStories
- Ensure assets exist in `assets/` or use Icons as fallback

---

### Task 14: Wire OutletMainScreen

**File:** `lib/src/ui/outlet/outlet_main_screen.dart`

- Replace Manage placeholder with `OutletManageView(outlet: o, userId: u!.userId)`

---

## File Summary

| Action | File |
|--------|------|
| Modify | `lib/src/api/api_path.dart` |
| Create | `lib/src/models/manage_outlet_store.dart` |
| Create | `lib/src/ui/outlet/outletManage/outlet_manage_view.dart` |
| Create | `lib/src/ui/outlet/outletManage/outlet_profile/outlet_profile_view.dart` |
| Create | `lib/src/ui/outlet/outletManage/outlet_offers/outlet_offers_view.dart` |
| Create | `lib/src/ui/outlet/outletManage/outlet_coupons/outlet_coupons_view.dart` |
| Create | `lib/src/ui/outlet/outletManage/outlet_reviews/outlet_reviews_view.dart` |
| Create | `lib/src/ui/outlet/outletManage/outlet_reports/outlet_reports.dart` |
| Create | `lib/src/ui/outlet/outletManage/outlet_delivery_area_and_charges/outlet_delivery_area_and_charges_view.dart` |
| Create | `lib/src/ui/outlet/outletManage/outlet_rider/outlet_rider_list_view.dart` |
| Create | `lib/src/ui/outlet/outletManage/outlet_whatsapp_stories/outlet_whatsapp_stories_view.dart` |
| + Add/Edit sub-views for each |
| Modify | `lib/src/common/assets_path.dart` |
| Modify | `lib/src/ui/outlet/outlet_main_screen.dart` |

---

## Flavor-specific behavior

- `activeApp.id == 'send_me_lebanon'`: hide id 7, 8, 5, 2
- `activeApp.id == 'send_me_talabetak'`: hide id 8, 2
- Use same logic as sendme `outlet_manage_view.dart`

---

## Optional Deferrals

- Some child screens (e.g. WhatsApp Stories, Riders) can be Phase 6 if time-constrained
- Start with Profile, Offers, Coupons, Reviews, Reports; add Delivery/Riders/WhatsApp later

---

## Verification

1. Manage tab loads and shows menu from API
2. Tapping each visible item navigates to correct screen
3. Profile: edit outlet, time slots, holidays
4. Offers: list, add, edit
5. Coupons: list, add, edit
6. Reviews: list, reply
7. Reports: show data
8. Hidden items per flavor do not appear
