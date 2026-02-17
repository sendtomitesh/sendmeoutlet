# Phase 4 – Full Add/Edit Product (Variants, Addons, Advanced Option)

> Reference: sendme `lib/src/ui/outlet/outletProducts/products/`

---

## Overview

sendme add/edit product supports:

1. **Simple product** – single price, no variants  
2. **Advanced Option** – units, weight, veg/nonveg, variants with addons  
3. **Variants** – size/color combinations (e.g. ecom)

---

## Structure

### Add Product

| File | Purpose |
|------|---------|
| `add_product_detail_view.dart` | Base form: name, price, category, description, image, units, weight. Branches to simple, advanced, or variant |
| `add_product_advance_option.dart` | Variants (title + variant list) + addons per variant. Pricedetails structure |
| `add_product_variant_option.dart` | Size/color variants (ecom style) |
| `add_product_by_variant.dart` | Add variant dialog |
| `bottomsheet.dart` | Product detail bottom sheet |
| `add_outlet_new_menu_by_category.dart` | ManageMenuItem API (add) |
| `add_product.dart` | ManageMenuItem API for advance flow |

### Edit Product

| File | Purpose |
|------|---------|
| `edit_product_view.dart` | Main edit form. Branches to EditProductDetailView or EditProductVariant |
| `edit_product_detail_view.dart` | Edit with variants/addons (advance flow) |
| `edit_product_variant.dart` | Edit variant products |
| `edit_menu_item.dart` | ManageMenuItem API (update) |

### Data Structures

- **Pricedetails** (ManageMenuItem):
  - Simple: `[{ Price, isDefault, subItemId, status, type, itemUnit, itemWeight, ... }]`
  - Variants: `[{ subItemCategoryId, Price, singleOptionTitle, multiOptionTitle, subItemId, subItemName, addon: [...], ... }]`
- **addon**: `[{ subItemId, addonId, name, price, type }]`
- **variantData**: `[{ Price, subItemName, variantId, isDefault, addOn: [...] }]`
- **addOnData**: standalone addon rows

---

## APIs

- `getAllUnits` – units for weight/measure
- `searchSubItems` – search existing sub-items
- `manageMenuItem` – add/update with Pricedetails
- `uploadToS3` – product images

---

## Flavor Checks

- `activeApp.id == 'send_me_lebanon'` – hide Advanced Option, Variants
- `isEcom` – show Variants link

---

## Implementation Order

1. Add models (Units, SearchSubMenu) and APIs – done  
2. Add base AddProductDetailView with 3 paths  
3. Add AddProductDetailWithAdvanceOptionView (variants + addons)  
4. Add AddProductDetailWithVariantView (size/color)  
5. Add AddOutletNewMenuByCategory, AddProduct (API)  
6. Add EditProductView, EditProductDetailView, EditProductVariant, EditMenuItem  
