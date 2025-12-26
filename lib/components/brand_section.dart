import 'package:flutter/material.dart';

class BrandSection extends StatefulWidget {
  final Function(String) onCategorySelected;

  BrandSection({super.key, required this.onCategorySelected});

  @override
  State<BrandSection> createState() => _BrandSectionState();
}

class _BrandSectionState extends State<BrandSection> {
  String selectedCategory = 'All';

  final List<Map<String, dynamic>> brands = [
    {'name': 'All', 'icon': Icons.category},
    {'name': 'Clothes', 'icon': Icons.checkroom},
    {'name': 'Electronics', 'icon': Icons.electrical_services},
    {'name': 'Furniture', 'icon': Icons.weekend},
    {'name': 'Shoes', 'icon': Icons.shop},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween),
          SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: brands.length,
              itemBuilder: (context, index) {
                final brand = brands[index];
                final bool isSelected = selectedCategory == brand['name'];

                return Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = brand['name'];
                      });
                      widget.onCategorySelected(brand['name']);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(0xFFFF9100)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            brand['icon'] as IconData,
                            color: isSelected ? Colors.white : Colors.black87,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            brand['name'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
