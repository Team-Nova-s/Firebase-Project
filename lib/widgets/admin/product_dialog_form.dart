import 'package:flutter/material.dart';
import 'package:papela/constants/constants.dart';
import 'package:papela/models/product.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import '../../utils/validators.dart';
import '../common/custom_text_field.dart';
import '../common/loading_button.dart';

class ProductFormDialog extends StatefulWidget {
  final ProductModel? product;

  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _quantityController.text = widget.product!.quantity.toString();
      _selectedCategoryId = widget.product!.categoryId;
      if (widget.product!.imageUrls.isNotEmpty) {
        _imageUrlController.text = widget.product!.imageUrls.first;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a category'), backgroundColor: AppColors.error),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    final product = ProductModel(
      id: widget.product?.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategoryId!,
      price: double.parse(_priceController.text),
      quantity: int.parse(_quantityController.text),
      imageUrls: _imageUrlController.text.trim().isNotEmpty
          ? [_imageUrlController.text.trim()]
          : [],
      specifications: {},
      createdAt: widget.product?.createdAt ?? DateTime.now(),
    );

    bool success;
    if (widget.product == null) {
      success = await productProvider.addProduct(product);
    } else {
      success = await productProvider.updateProduct(widget.product!.id, product);
    }

    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.product == null ? 'Product added successfully' : 'Product updated successfully',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.product == null ? 'Add Product' : 'Edit Product',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  CustomTextField(
                    controller: _nameController,
                    label: 'Product Name',
                    hintText: 'Enter product name',
                    validator: Validators.required,
                  ),
                  SizedBox(height: 16),

                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hintText: 'Enter product description',
                    maxLines: 3,
                    validator: Validators.required,
                  ),
                  SizedBox(height: 16),

                  Consumer<ProductProvider>(
                    builder: (context, productProvider, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategoryId,
                            decoration: InputDecoration(
                              hintText: 'Select category',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: productProvider.categories.map((category) {
                              return DropdownMenuItem(
                                value: category.id,
                                child: Text(category.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedCategoryId = value);
                            },
                            validator: (value) => value == null ? 'Please select a category' : null,
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _priceController,
                          label: 'Price (GH₵)',
                          hintText: 'Enter price',
                          keyboardType: TextInputType.number,
                          validator: Validators.price,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: _quantityController,
                          label: 'Quantity',
                          hintText: 'Enter quantity',
                          keyboardType: TextInputType.number,
                          validator: Validators.quantity,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  CustomTextField(
                    controller: _imageUrlController,
                    label: 'Image URL (Optional)',
                    hintText: 'Enter image URL',
                    keyboardType: TextInputType.url,
                  ),
                  SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel'),
                      ),
                      SizedBox(width: 16),
                      LoadingButton(
                        onPressed: _saveProduct,
                        isLoading: _isLoading,
                        child: Text(widget.product == null ? 'Add Product' : 'Update Product'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
