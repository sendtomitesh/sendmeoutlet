# sendme_outlet – Implementation Roadmap

> Reference: `sendme/lib/src/ui/outlet/` for all outlet flows.

## Phase Plans

| Phase | Plan |
|-------|------|
| 2a | [PHASE_2A_PLAN.md](PHASE_2A_PLAN.md) |
| 2b | [PHASE_2B_PLAN.md](PHASE_2B_PLAN.md) |
| 3 | [PHASE_3_PLAN.md](PHASE_3_PLAN.md) |
| 4 | [PHASE_4_PLAN.md](PHASE_4_PLAN.md) |
| 5 | [PHASE_5_PLAN.md](PHASE_5_PLAN.md) |
| 6 | [PHASE_6_PLAN.md](PHASE_6_PLAN.md) |

## Key Principles

1. **Outlet-only app** – No user switching, no `UserAccount`, `UserMainScreen`, or `UserOutletMainScreen`.
2. **Outlet data fetch** – Uses `SwitchUser?userType=Outlet&mobileNumber=...` API; on failure → show error + logout (no redirect to user app).
3. **Reference** – Use `sendme/lib/src/ui/outlet/` as source of truth; copy and adapt only what's needed for sendme_outlet.

---

## sendme Outlet Structure (Reference)

| Component | Path | Role |
|-----------|------|------|
| **Outlet Main** | `outlet_main_screen.dart` | Bottom nav; fetches outlet via `fetchOutletData` (SwitchUser API); builds tabs |
| **Home** | `outletHome/outlet_home_page.dart` | Dashboard: status toggle, overview stats, active orders preview, Add Order, Upload Prescription/Items (grocery/medicine) |
| **Orders** | `outletOrder/outlet_order_tab.dart` → `get_outlet_order_list.dart` | Tabs: Today Order, Pending, All Order, Order Summary (3 tabs for Lebanon/Talabetak) |
| **Products** | `outletProducts/catalogue_view.dart` | Categories, SubCategories, Products (hidden for Grocery/Medicine) |
| **Manage** | `outletManage/outlet_manage_view.dart` | Dynamic list from `GetStoreMenuTab` API → Offers, Coupons, Reviews, Reports, Riders, Profile, Delivery Area, WhatsApp Stories |
| **Account** | `user_ui/account/user_account.dart` | Profile + switch user → **Replace with** Outlet Account (profile + logout only) |

Theme variants: `themeId == Grocery_Store_UI` and `isMedicine == 1` hide Products tab and change Home buttons.

---

## Phase 1: Foundation ✅ (Done)

- [x] Auth flow: Login, OTP verification, Location
- [x] Demo Home placeholder
- [x] `prefUserData` storage

---

## Phase 2a: Outlet Main Screen & Data Fetch

> **Detailed plan:** See [PHASE_2A_PLAN.md](PHASE_2A_PLAN.md)

**Goal:** Replace Demo Home with Outlet Main Screen and bottom nav.

1. **Outlet model** – Add `Outlet` model (from sendme) if not present.
2. **SwitchUser API** – Implement `fetchOutletData` using `SwitchUser?userType=Outlet&mobileNumber=${u.mobile}&deviceType=...&version=...&deviceId=...`.
3. **prefOutletData** – Store outlet response in shared_preferences.
4. **GlobalConstants** – Set `outletCityId`, `outletCountryCode`, `outletCurrency`, `outletStatus`, `themeId`, `isMedicine`, etc. from response.
5. **Error handling** – If outlet fetch fails or user has no outlet: show toast + logout (clear prefs, go to Login). Do **not** redirect to user app.
6. **Blocked user** – If `isBlocked == 1`, clear prefs and go to Login.
7. **Force update** – Preserve `forceUpdate` / `MessageForForceUpdate` logic.
8. **Outlet Main Screen** – Create `OutletMainScreen`:
   - `FutureBuilder` on `fetchOutletData`.
   - Bottom nav tabs based on `themeId` / `isMedicine`:
     - Restaurant: Home | Orders | Products | Manage | Account
     - Grocery/Medicine: Home | Orders | Manage | Account
9. **Outlet Account tab** – Simple Account tab with profile + logout only (no switch user).
10. **main.dart** – AuthGate: if logged in → `OutletMainScreen`; else → Login.

---

## Phase 2b: Home & Account Tabs

> **Detailed plan:** See [PHASE_2B_PLAN.md](PHASE_2B_PLAN.md)

**Home tab** (from `outlet_home_page.dart`):

- Outlet avatar, name, Available/Unavailable toggle.
- Power button to change status → `UpdateOutletStatus` API.
- Bottom sheet when going offline: “Go online after” (1h, 2h, 4h, tomorrow, manual).
- Overview section with dropdown: Today, Yesterday, This Week, This Month.
- Cards: Total Amount, Total Orders, Delivered, Overall Rating.
- `GetOutletDashboardData` API.
- WhatsApp opt-in banner (if needed).
- Add Order button (→ `AddOrder` for restaurant).
- Upload Prescription / Upload Items List / Enter Items List for grocery/medicine.
- Active orders preview (link to Orders tab).
- `fetchOutletOrders` for pending orders.

**Account tab** (outlet-only):

- Outlet/user profile info (read-only or edit if needed).
- Logout → clear prefs, go to Login.

---

## Phase 3: Orders Tab

> **Detailed plan:** See [PHASE_3_PLAN.md](PHASE_3_PLAN.md)

**From** `outlet_order_tab.dart` + `get_outlet_order_list.dart`:

- Sub-tabs: Today Order, Pending, All Order, Order Summary (optional per flavor).
- `GetOrderList` API with `dateType`, `type` (status).
- Order cards: order id, status, customer, phone, order time, delivery time, rider, total bill.
- Tap order → `GetOutletOrderDetails`.
- Accept, Reject, Order Prepared actions.
- Order Summary tab: aggregated view from `OrderSummaryView`.

---

## Phase 4: Products Tab (Catalogue)

> **Detailed plan:** See [PHASE_4_PLAN.md](PHASE_4_PLAN.md)

**Only for restaurant theme** (not Grocery/Medicine):

- From `catalogue_view.dart`, `categories_view.dart`, `sub_categories_view.dart`, `products_view.dart`.
- Tabs: Categories | SubCategories | Products.
- CRUD: add/edit/delete categories, subcategories, menu items.
- APIs: `ManageCategory`, `ManageSubCategory`, `ManageMenuItem`, etc.
- Search: `SuperSearch` or equivalent.

---

## Phase 5: Manage Tab

> **Detailed plan:** See [PHASE_5_PLAN.md](PHASE_5_PLAN.md)

**From** `outlet_manage_view.dart`:

- Fetch manage menu from `GetStoreMenuTab` API.
- List items and navigate to:
  - Offers (`OutletOffersView`)
  - Coupons (`OutletCouponsView`)
  - Reviews (`OutletReviewsView`)
  - Bill Reports (`OutletBillReports`)
  - Riders (`OutletRiderListView`)
  - Outlet Profile (`OutletProfileView`)
  - Delivery Area & Charges (`OutletDeliveryAreaAndChargesView`)
  - WhatsApp Stories (`OutletWhatsappStoriesView`)
- Hide items per flavor (e.g. Lebanon, Talabetak) if needed.

---

## Phase 6: Extras & Polish

> **Detailed plan:** See [PHASE_6_PLAN.md](PHASE_6_PLAN.md)

- Add Order flow (`add_order.dart`, `manual_add_order_for_medicine_and_grocery.dart`).
- Get Order Details (`get_outlet_order_details.dart`).
- Manual add order for grocery/medicine.
- Generate WebStore Link.
- Time slots (`addtimeslotstooutlet`, `gettimeslotsbyoutletid`).
- Missing assets, localization, error pages.

---

## What sendme_outlet Does NOT Need

| From sendme | In sendme_outlet |
|-------------|------------------|
| `UserAccount` | Replace with Outlet Account (profile + logout only) |
| Switch to user | **Remove entirely** |
| `UserMainScreen` | **Remove** |
| `UserOutletMainScreen` | **Remove** |
| On outlet fetch fail → UserMainScreen/UserOutletMainScreen | On fail → show error + logout → Login |
| Rider/Admin screens | **Remove** |

---

## Implementation Order

1. **Phase 2a** – Outlet Main Screen + fetch + basic tabs
2. **Phase 2b** – Home tab + Account tab
3. **Phase 3** – Orders tab
4. **Phase 4** – Products tab (restaurant only)
5. **Phase 5** – Manage tab
6. **Phase 6** – Add order, details, grocery/medicine flows, polish
