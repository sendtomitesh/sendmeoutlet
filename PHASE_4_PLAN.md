# Phase 4: Products Tab (Catalogue) – Implementation Plan

> **Goal:** Full Products/Catalogue tab for restaurant theme. Categories, SubCategories, Products with CRUD. **Not for Grocery/Medicine** (tab hidden for those themes).

---

## Prerequisites

- Phase 2a, 2b, 3 complete
- Products tab visible only when `themeId != Grocery_Store_UI` and `isMedicine != 1` (already in OutletMainScreen from Phase 2a)

---

## Current State

| Item | Status |
|------|--------|
| Products tab | Placeholder or empty from Phase 2a |
| Catalogue | Full implementation needed |
| Category/SubCategory/Product models | ❌ Add |
| ManageCategory, ManageSubCategory, ManageMenuItem APIs | ❌ Add |

---

## Reference Structure (sendme)

- `outletProducts/catalogue_view.dart` – Main wrapper, TabController (Categories | SubCategories | Products or 3 tabs for Grocery_Menu_UI)
- `outletProducts/categories/categories_view.dart` – List of categories, add/edit/delete
- `outletProducts/subCategories/sub_categories_view.dart` – Subcategories
- `outletProducts/products/products_view.dart` – Products list
- Add/Edit forms for each
- `ManageCategory`, `ManageSubCategory`, `ManageMenuItem` APIs
- `getOutletWiseProductCategories`, `getOutletSubCategories`, `getCategoriesWiseOutletProducts`
- `GetHotelDetail` for outlet detail
- Search: `SuperSearch` or `SearchItems`

---

## Tasks (in order)

### Task 1: Add API paths

**File:** `lib/src/api/api_path.dart`

Add:

- `manageCategory` – `slsServerPath + 'ManageCategory'`
- `manageSubCategory` – `slsServerPath + 'ManageSubCategory'`
- `manageMenuItem` – `slsServerPath + 'ManageMenuItem'`
- `getOutletWiseProductCategories` – `slsServerPath + 'GetOutletWiseProductCategories'`
- `getOutletSubCategories` – `slsServerPath + 'GetOutletSubCategory'`
- `getCategoriesWiseOutletProducts` – `slsServerPath + 'GetCategoryWiseOutletProducts'`
- `updateOutletCategoryStatus` – `slsServerPath + 'UpdateOutletCategoryStatus?'`
- `getHotelDetail` – `slsServerPath + 'GetHotelDetail?'` (if not added in Phase 2b)
- `searchItems` – `slsServerPath + 'SearchItems?'`

---

### Task 2: Add models

**Files to create (copy from sendme):**

- `lib/src/models/outlet_menu.dart` – Category/SubCategory/Product structure
- `lib/src/models/outlet_list.dart` – OutletList if needed for search
- Any category, subcategory, product item models used by catalogue

---

### Task 3: Add GlobalConstants

**File:** `lib/src/common/global_constants.dart`

- `Grocery_Menu_UI` – if not present
- `tabControllerCategoryId` – for catalogue tab state
- Any other constants used by catalogue (e.g. Default_MenuItems_UI, Image_MenuItems_UI)

---

### Task 4: Create CatalogueView

**File:** `lib/src/ui/outlet/outletProducts/catalogue_view.dart` (new)

Reference: `sendme/lib/src/ui/outlet/outletProducts/catalogue_view.dart`

**Structure:**

- TabController: length 2 (Categories, SubCategories, Products) or 3 for Grocery_Menu_UI
- AppBar: title "Catalogue", optional search icon
- TabBar: Categories | SubCategories | Products
- TabBarView:
  - `CategoriesView(outlet: widget.outlet)`
  - `SubCategoriesView(outlet: widget.outlet)`
  - `ProductsView(outlet: widget.outlet)`
- `fetchOutletDetail()` for subDomain/outlet details if needed
- Search: toggle search bar, `productSearchValue`, `categorySearchValue`

---

### Task 5: Create CategoriesView

**File:** `lib/src/ui/outlet/outletProducts/categories/categories_view.dart` (new)

- List categories from API: `getOutletWiseProductCategories` or equivalent
- Add category button → `AddNewCategoryView` or inline form
- Edit category → `EditCategoryView`
- Delete category (with confirmation)
- API: `ManageCategory` for add/edit, `updateOutletCategoryStatus` for delete/status
- Reference: `sendme/.../categories/categories_view.dart`

---

### Task 6: Create SubCategoriesView

**File:** `lib/src/ui/outlet/outletProducts/subCategories/sub_categories_view.dart` (new)

- List subcategories for selected category
- Add/Edit/Delete subcategories
- API: `getOutletSubCategories`, `ManageSubCategory`
- Reference: `sendme/.../subCategories/sub_categories_view.dart`

---

### Task 7: Create ProductsView

**File:** `lib/src/ui/outlet/outletProducts/products/products_view.dart` (new)

- List products from API: `getCategoriesWiseOutletProducts`
- Add product → `AddProductView`
- Edit product → `EditProductView`
- Delete / toggle availability
- API: `ManageMenuItem`
- Reference: `sendme/.../products/products_view.dart`

---

### Task 8: Add/Edit forms

Create as needed (can be phased):

- `categories/add_new_category.dart`, `edit_category_view.dart`
- `subCategories/add_new_sub_category.dart`, `edit_sub_category_view.dart`
- `products/add_product/add_product_view.dart`, `edit_product/edit_product_view.dart`

These can be complex (variants, options, images). Start with basic add/edit, expand in Phase 6.

---

### Task 9: Search (optional)

- Integrate `SuperSearch` or simple search using `searchItems` API
- Can defer to Phase 6 if time-constrained

---

### Task 10: Wire OutletMainScreen

**File:** `lib/src/ui/outlet/outlet_main_screen.dart`

- Replace Products placeholder with `CatalogueView(outlet: o)` (already in _children for restaurant theme)
- Grocery/Medicine: keep `MessageForEmptyPage` or hide tab (already done in Phase 2a)

---

## File Summary

| Action | File |
|--------|------|
| Modify | `lib/src/api/api_path.dart` |
| Create | `lib/src/models/outlet_menu.dart` |
| Create | `lib/src/models/outlet_list.dart` (if needed) |
| Modify | `lib/src/common/global_constants.dart` |
| Create | `lib/src/ui/outlet/outletProducts/catalogue_view.dart` |
| Create | `lib/src/ui/outlet/outletProducts/categories/categories_view.dart` |
| Create | `lib/src/ui/outlet/outletProducts/categories/add_new_category.dart` |
| Create | `lib/src/ui/outlet/outletProducts/categories/edit_category_view.dart` |
| Create | `lib/src/ui/outlet/outletProducts/subCategories/sub_categories_view.dart` |
| Create | `lib/src/ui/outlet/outletProducts/subCategories/add_new_sub_category.dart` |
| Create | `lib/src/ui/outlet/outletProducts/subCategories/edit_sub_category_view.dart` |
| Create | `lib/src/ui/outlet/outletProducts/products/products_view.dart` |
| Create | `lib/src/ui/outlet/outletProducts/products/add_product/*` |
| Create | `lib/src/ui/outlet/outletProducts/products/edit_product/*` |
| Modify | `lib/src/ui/outlet/outlet_main_screen.dart` |

---

## Dependencies

- Image picker for product/category images
- Possibly `flutter_svg` for icons
- Multi-part form handling for variants (product options)

---

## Optional Deferrals

- Product variants (size, add-ons) → Phase 6
- Search → Phase 6
- Bulk operations → Phase 6

---

## Verification

1. Products tab visible only for restaurant theme
2. Categories tab loads and displays categories
3. Add/Edit/Delete category works
4. SubCategories tab loads for selected category
5. Add/Edit/Delete subcategory works
6. Products tab loads products
7. Add/Edit/Delete product works (basic)
8. Tab switching preserves state where needed
