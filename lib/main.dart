import 'package:flutter/material.dart';
import 'package:lab1flutter/product.dart';
import 'package:lab1flutter/product_store.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 1 — Sản phẩm',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ProductHomePage(),
    );
  }
}

class ProductHomePage extends StatefulWidget {
  const ProductHomePage({super.key});

  @override
  State<ProductHomePage> createState() => _ProductHomePageState();
}

class _ProductHomePageState extends State<ProductHomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _visible {
    final q = _searchController.text;
    return ProductStore.searchByName(q);
  }

  void _refresh() => setState(() {});

  String _formatPrice(double p) {
    final s = p.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${buf.toString()} đ';
  }

  Future<void> _showProductDialog({Product? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final imageCtrl = TextEditingController(text: existing?.image ?? '');
    final priceCtrl = TextEditingController(
      text: existing != null ? existing.price.toStringAsFixed(0) : '',
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên'),
              ),
              TextField(
                controller: imageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ảnh (URL hoặc đường dẫn)',
                ),
              ),
              TextField(
                controller: priceCtrl,
                decoration: const InputDecoration(labelText: 'Giá'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (ok != true || !context.mounted) return;

    final price = double.tryParse(priceCtrl.text.replaceAll('.', ''));
    if (nameCtrl.text.trim().isEmpty || price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên / giá không hợp lệ')),
      );
      return;
    }

    if (existing == null) {
      ProductStore.add(
        Product(
          id: 0,
          name: nameCtrl.text.trim(),
          image: imageCtrl.text.trim(),
          price: price,
        ),
      );
    } else {
      ProductStore.update(
        existing.copyWith(
          name: nameCtrl.text.trim(),
          image: imageCtrl.text.trim(),
          price: price,
        ),
      );
    }
    _refresh();
  }

  void _confirmDelete(Product p) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa sản phẩm?'),
        content: Text('Xóa "${p.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              ProductStore.removeById(p.id);
              Navigator.pop(ctx);
              _refresh();
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _visible;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 1 — Quản lý Product'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'raw') {
                debugPrint(ProductStore.displayAll());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã in danh sách ra console (debugPrint)'),
                  ),
                );
                return;
              }
              if (v == 'p_asc') {
                ProductStore.sortByPrice(ascending: true);
              } else if (v == 'p_desc') {
                ProductStore.sortByPrice(ascending: false);
              } else if (v == 'n_asc') {
                ProductStore.sortByName(ascending: true);
              } else if (v == 'n_desc') {
                ProductStore.sortByName(ascending: false);
              } else if (v == 'id') {
                ProductStore.sortById();
              }
              _refresh();
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'p_asc', child: Text('Giá tăng dần')),
              PopupMenuItem(value: 'p_desc', child: Text('Giá giảm dần')),
              PopupMenuItem(value: 'n_asc', child: Text('Tên A→Z')),
              PopupMenuItem(value: 'n_desc', child: Text('Tên Z→A')),
              PopupMenuItem(value: 'id', child: Text('Sắp xếp theo id')),
              PopupMenuItem(
                value: 'raw',
                child: Text('Hiển thị chuỗi (console)'),
              ),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _refresh();
                        },
                      )
                    : null,
              ),
              onChanged: (_) => _refresh(),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('Không có sản phẩm phù hợp'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: list.length,
                    itemBuilder: (ctx, i) {
                      final p = list[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 56,
                              height: 56,
                              child: _ProductThumb(urlOrPath: p.image),
                            ),
                          ),
                          title: Text(p.name),
                          subtitle: Text('id: ${p.id}'),
                          trailing: Text(
                            _formatPrice(p.price),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () => _showProductDialog(existing: p),
                          onLongPress: () => _confirmDelete(p),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.urlOrPath});

  final String urlOrPath;

  @override
  Widget build(BuildContext context) {
    if (urlOrPath.isEmpty) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.image_not_supported_outlined),
      );
    }
    if (urlOrPath.startsWith('http://') || urlOrPath.startsWith('https://')) {
      return Image.network(
        urlOrPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.broken_image_outlined),
        ),
      );
    }
    return Image.asset(
      urlOrPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.broken_image_outlined),
      ),
    );
  }
}
