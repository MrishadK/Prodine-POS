import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/menu_item.dart';
import '../providers/menu_provider.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key});

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  // Controllers for Portions
  final _priceQuarterController = TextEditingController();
  final _priceHalfController = TextEditingController();
  final _priceThreeQuarterController = TextEditingController();

  bool _enablePortions = false;
  String? _selectedCategory;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _priceQuarterController.dispose();
    _priceHalfController.dispose();
    _priceThreeQuarterController.dispose();
    super.dispose();
  }

  // --- ACTIONS ---

  void _addNewCategory() {
    final TextEditingController newCatController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Category"),
        content: TextField(
          controller: newCatController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "e.g., Burgers, Drinks...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C5F7C),
                foregroundColor: Colors.white),
            onPressed: () {
              if (newCatController.text.trim().isNotEmpty) {
                final newCat = newCatController.text.trim();
                // ✅ Save to provider (Persists even if empty)
                ref.read(categoriesProvider.notifier).addCategory(newCat);
                setState(() {
                  _selectedCategory = newCat; // Auto-select
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  void _deleteCategory() {
    if (_selectedCategory == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete '${_selectedCategory}'?"),
        content: const Text(
            "This will delete the category and ALL items inside it.\nThis action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              // 1. Delete items inside this category
              ref
                  .read(menuProvider.notifier)
                  .deleteItemsInCategory(_selectedCategory!);

              // 2. Delete the category itself
              ref
                  .read(categoriesProvider.notifier)
                  .removeCategory(_selectedCategory!);

              // 3. Reset selection
              setState(() {
                _selectedCategory = null;
              });
              Navigator.pop(context);
            },
            child: const Text("Confirm Delete"),
          )
        ],
      ),
    );
  }

  void _saveItem() {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please create or select a category first!'),
          backgroundColor: Colors.red));
      return;
    }

    if (_formKey.currentState!.validate()) {
      final newItem = MenuItem(
        id: const Uuid().v4(),
        name: _nameController.text,
        price: double.parse(_priceController.text),
        category: _selectedCategory!,
        priceQuarter: _enablePortions && _priceQuarterController.text.isNotEmpty
            ? double.tryParse(_priceQuarterController.text)
            : null,
        priceHalf: _enablePortions && _priceHalfController.text.isNotEmpty
            ? double.tryParse(_priceHalfController.text)
            : null,
        priceThreeQuarter:
            _enablePortions && _priceThreeQuarterController.text.isNotEmpty
                ? double.tryParse(_priceThreeQuarterController.text)
                : null,
      );

      ref.read(menuProvider.notifier).addMenuItem(newItem);

      // Clear fields but keep category selected
      _nameController.clear();
      _priceController.clear();
      _priceQuarterController.clear();
      _priceHalfController.clear();
      _priceThreeQuarterController.clear();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Item Added Successfully!'),
          backgroundColor: Colors.green));
    }
  }

  // --- UI BUILDER ---

  @override
  Widget build(BuildContext context) {
    final allItems = ref.watch(menuProvider);
    // ✅ Watch categories so they don't vanish
    final availableCategories = ref.watch(categoriesProvider);

    // Auto-select logic if current selection is invalid
    if (_selectedCategory != null &&
        !availableCategories.contains(_selectedCategory)) {
      _selectedCategory = null;
    }
    if (_selectedCategory == null && availableCategories.isNotEmpty) {
      _selectedCategory = availableCategories.first;
    }

    // Filter items based on selection
    final categoryItems = _selectedCategory == null
        ? <MenuItem>[]
        : allItems.where((i) => i.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF0),
      appBar: AppBar(
          title: const Text('Menu Management',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF2C5F7C),
          foregroundColor: Colors.white),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- LEFT SIDE: FORM ----------------
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05), blurRadius: 10)
                    ]),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add New Item',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C5F7C))),
                      const SizedBox(height: 24),

                      // 1. CATEGORY SELECTION (Improved)
                      if (availableCategories.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: Colors.orange),
                              const SizedBox(width: 12),
                              const Expanded(
                                  child: Text(
                                      "No categories found. Create one to start adding items.")),
                              ElevatedButton.icon(
                                onPressed: _addNewCategory,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text("Create"),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white),
                              )
                            ],
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                items: availableCategories
                                    .map((c) => DropdownMenuItem(
                                        value: c, child: Text(c)))
                                    .toList(),
                                onChanged: (v) => setState(
                                    () => _selectedCategory = v.toString()),
                                decoration: const InputDecoration(
                                    labelText: 'Select Category',
                                    prefixIcon: Icon(Icons.category),
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Color(0xFFFAFAFA)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Action Buttons
                            Container(
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Row(
                                children: [
                                  IconButton(
                                      icon: const Icon(Icons.add_box,
                                          color: Colors.green),
                                      onPressed: _addNewCategory,
                                      tooltip: "New Category"),
                                  Container(
                                      width: 1,
                                      height: 24,
                                      color: Colors.grey.shade300),
                                  IconButton(
                                      icon: const Icon(Icons.delete_forever,
                                          color: Colors.red),
                                      onPressed: _deleteCategory,
                                      tooltip: "Delete Category"),
                                ],
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 20),

                      // 2. ITEM DETAILS
                      TextFormField(
                          controller: _nameController,
                          enabled: availableCategories.isNotEmpty,
                          decoration: const InputDecoration(
                              labelText: 'Food Name',
                              prefixIcon: Icon(Icons.fastfood),
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFFFAFAFA)),
                          validator: (v) => v!.isEmpty ? 'Required' : null),
                      const SizedBox(height: 16),
                      TextFormField(
                          controller: _priceController,
                          enabled: availableCategories.isNotEmpty,
                          decoration: const InputDecoration(
                              labelText: 'Base Price',
                              prefixIcon: Icon(Icons.attach_money),
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFFFAFAFA)),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Required' : null),
                      const SizedBox(height: 16),

                      // 3. PORTIONS TOGGLE
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SwitchListTile(
                            title: const Text('Enable Custom Portions',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: const Text("Quarter, Half, 3/4 pricing"),
                            activeColor: const Color(0xFF2C5F7C),
                            value: _enablePortions,
                            onChanged: availableCategories.isEmpty
                                ? null
                                : (v) => setState(() => _enablePortions = v)),
                      ),

                      if (_enablePortions) ...[
                        const SizedBox(height: 16),
                        Row(children: [
                          Expanded(
                              child: _buildMiniPriceField(
                                  _priceQuarterController, '0.25 Price')),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _buildMiniPriceField(
                                  _priceHalfController, '0.50 Price')),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _buildMiniPriceField(
                                  _priceThreeQuarterController, '0.75 Price')),
                        ])
                      ],

                      const SizedBox(height: 30),

                      // SAVE BUTTON
                      SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                              onPressed: availableCategories.isEmpty
                                  ? null
                                  : _saveItem,
                              icon: const Icon(Icons.save),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey.shade300,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  elevation: 2),
                              label: const Text('SAVE ITEM',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)))),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const VerticalDivider(width: 1, thickness: 1),

          // ---------------- RIGHT SIDE: LIST PREVIEW ----------------
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Header for List
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: const Color(0xFFF5F7FA),
                    child: Text(
                      _selectedCategory != null
                          ? "Items in '$_selectedCategory'"
                          : "Items List",
                      style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  // The List
                  Expanded(
                    child: _selectedCategory == null ||
                            availableCategories.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.menu_book,
                                    size: 60, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text("No Category Selected",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Text(
                                    "Create or select a category to view items.",
                                    style:
                                        TextStyle(color: Colors.grey.shade400)),
                              ],
                            ),
                          )
                        : categoryItems.isEmpty
                            ? Center(
                                child: Text("No items in this category yet.",
                                    style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontStyle: FontStyle.italic)),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: categoryItems.length,
                                separatorBuilder: (c, i) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final item = categoryItems[index];
                                  return Card(
                                    elevation: 1,
                                    margin: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            const Color(0xFFE3F2FD),
                                        child: Text(item.name[0].toUpperCase(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2C5F7C))),
                                      ),
                                      title: Text(item.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Text(
                                        'Full: ${item.price} SAR'
                                        '${item.priceHalf != null ? " | Half: ${item.priceHalf}" : ""}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600),
                                      ),
                                      trailing: IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          tooltip: "Delete Item",
                                          onPressed: () => ref
                                              .read(menuProvider.notifier)
                                              .deleteItem(item.id)),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPriceField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
    );
  }
}
