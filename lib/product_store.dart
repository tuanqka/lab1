import 'package:lab1flutter/product.dart';

enum SortMode { none, priceAsc, priceDesc, nameAsc, nameDesc, idAsc }

class ProductStore {
  ProductStore._();

  static final List<Product> _products = [
    Product(
      id: 1,
      name: 'Laptop',
      image: 'https://picsum.photos/seed/lab1a/200',
      price: 15_990_000,
    ),
    Product(
      id: 2,
      name: 'Chuột không dây',
      image: 'https://picsum.photos/seed/lab1b/200',
      price: 350_000,
    ),
    Product(
      id: 3,
      name: 'Bàn phím cơ',
      image: 'https://picsum.photos/seed/lab1c/200',
      price: 2_190_000,
    ),
  ];

  static int _nextId = 4;
  static SortMode _sortMode = SortMode.none;

  static List<Product> get products => List.unmodifiable(_products);

  static SortMode get sortMode => _sortMode;

  static String displayAll() {
    if (_products.isEmpty) return '(trống)';
    return _products.map((p) => p.toString()).join('\n');
  }

  static void add(Product product) {
    int id;
    if (product.id > 0 && !_products.any((p) => p.id == product.id)) {
      id = product.id;
      if (id >= _nextId) _nextId = id + 1;
    } else {
      id = _nextId++;
    }
    _products.add(product.copyWith(id: id));
    _reapplySort();
  }

  static bool removeById(int id) {
    final i = _products.indexWhere((p) => p.id == id);
    if (i < 0) return false;
    _products.removeAt(i);
    return true;
  }

  static bool update(Product updated) {
    final i = _products.indexWhere((p) => p.id == updated.id);
    if (i < 0) return false;
    _products[i] = updated;
    _reapplySort();
    return true;
  }

  static Product? findById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Product> searchByName(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List<Product>.from(_products);
    return _products
        .where((p) => p.name.toLowerCase().contains(q))
        .toList(growable: false);
  }

  static List<Product> searchByPriceRange(double min, double max) {
    return _products
        .where((p) => p.price >= min && p.price <= max)
        .toList(growable: false);
  }

  static void sortByPrice({required bool ascending}) {
    _sortMode = ascending ? SortMode.priceAsc : SortMode.priceDesc;
    _applySort();
  }

  static void sortByName({required bool ascending}) {
    _sortMode = ascending ? SortMode.nameAsc : SortMode.nameDesc;
    _applySort();
  }

  static void sortById({bool ascending = true}) {
    _sortMode = SortMode.idAsc;
    _applySort();
  }

  static void clearSort() {
    _sortMode = SortMode.none;
  }

  static void _applySort() {
    switch (_sortMode) {
      case SortMode.priceAsc:
        _products.sort((a, b) => a.price.compareTo(b.price));
      case SortMode.priceDesc:
        _products.sort((a, b) => b.price.compareTo(a.price));
      case SortMode.nameAsc:
        _products.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case SortMode.nameDesc:
        _products.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      case SortMode.idAsc:
        _products.sort((a, b) => a.id.compareTo(b.id));
      case SortMode.none:
        break;
    }
  }

  static void _reapplySort() {
    if (_sortMode != SortMode.none) _applySort();
  }
}
