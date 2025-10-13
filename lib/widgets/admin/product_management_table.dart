import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:papela/constants/constants.dart';
import 'package:papela/models/product.dart';

class ProductManagementTable extends StatelessWidget {
  final List<ProductModel> products;
  final Function(ProductModel) onEdit;
  final Function(ProductModel) onDelete;

  const ProductManagementTable({
    super.key,
    required this.products,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('Image')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Quantity')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: products.map((product) {
            return DataRow(
              cells: [
                DataCell(
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                    ),
                    child: product.imageUrls.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: product.imageUrls.first,
                              fit: BoxFit.cover,
                              errorWidget: (context, error, stackTrace) =>
                                  Icon(Icons.image_not_supported, size: 20),
                            ),
                          )
                        : Icon(Icons.image_not_supported, size: 20),
                  ),
                ),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (product.description.isNotEmpty)
                        Text(
                          product.description,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    'GH₵ ${product.price.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataCell(Text(product.categoryId)),
                DataCell(
                  Text(
                    '${product.quantity}',
                    style: TextStyle(
                      color: product.quantity > 0 ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.isAvailable
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: product.isAvailable ? AppColors.success : AppColors.error,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          product.isAvailable ? Icons.check_circle : Icons.cancel,
                          color: product.isAvailable ? AppColors.success : AppColors.error,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          product.isAvailable ? 'Available' : 'Unavailable',
                          style: TextStyle(
                            color: product.isAvailable ? AppColors.success : AppColors.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => onEdit(product),
                        icon: Icon(Icons.edit, size: 18),
                        tooltip: 'Edit Product',
                        padding: EdgeInsets.all(8),
                        constraints: BoxConstraints(),
                      ),
                      SizedBox(width: 4),
                      IconButton(
                        onPressed: () => onDelete(product),
                        icon: Icon(Icons.delete, size: 18, color: AppColors.error),
                        tooltip: 'Delete Product',
                        padding: EdgeInsets.all(8),
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
