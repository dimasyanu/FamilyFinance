import 'package:family_financial_app/models/requests/save_category.dart';
import 'package:family_financial_app/plugins/api_category.dart';
import 'package:family_financial_app/plugins/size_util.dart';
import 'package:family_financial_app/plugins/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:loader_overlay/loader_overlay.dart';

class CategoriesFormPage extends StatefulWidget {
  final String? itemId;
  final VoidCallback? onClosed;
  final Color backgroundColor;
  final Color foregroundColor;
  get isNew => itemId == null || itemId!.isEmpty;

  const CategoriesFormPage({
    this.itemId,
    this.onClosed,
    required this.backgroundColor,
    required this.foregroundColor,
    super.key,
  });

  @override
  State<CategoriesFormPage> createState() => _CategoriesFormPageState();
}

class _CategoriesFormPageState extends State<CategoriesFormPage> {
  Color _pickerColor = Color.fromARGB(255, 255, 255, 255);

  final _formKey = GlobalKey<FormState>();

  String? _categoryName = '';
  String? _description = '';
  final _icon = ValueNotifier<int>(0);

  final _colorController = TextEditingController();
  final _categoryNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _iconController = TextEditingController();

  bool _isLoaded = false;

  Future<void> loadCategoryData(BuildContext context) async {
    final api = ApiCategory(context);
    final messager = ScaffoldMessenger.of(context);
    try {
      final response = await api.getCategoryById(categoryId: widget.itemId!);

      if (response.hasError) {
        throw Exception('Failed to load category: ${response.message}');
      }

      final color = response.data?.color ?? '#000000';
      setState(() {
        _categoryName = response.data?.name ?? '';
        _description = response.data?.description ?? '';
        _icon.value = response.data?.icon ?? 0;

        _categoryNameController.text = _categoryName ?? '';
        _descriptionController.text = _description ?? '';
        _pickerColor = Utils.hexStringToColor(color);
        _colorController.text = color;
      });
    } catch (error) {
      messager.showSnackBar(
        SnackBar(
          content: Text('Error loading category: $error'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  Future<void> loadFormData(BuildContext context) async {
    if (!widget.isNew && !_isLoaded) {
      await loadCategoryData(context);
      _isLoaded = true;
      return;
    }
    // _color = '#000000'; // Default color for new category
    _pickerColor = Utils.hexStringToColor(_colorController.text);
  }

  @override
  Widget build(BuildContext context) {
    final sizeUtil = SizeUtil(context);
    final messager = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'New Category' : 'Category Detail'),
      ),
      body: LoaderOverlay(
        child: Container(
          padding: sizeUtil.dynamicPadding(
            maxXPercentage: .1,
            maxYPercentage: .04,
          ),
          child: Column(
            children: <Widget>[
              FutureBuilder(
                future: loadFormData(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading categories: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  context.loaderOverlay.hide();

                  return Form(
                    key: _formKey,
                    child: Column(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextFormField(
                          controller: _categoryNameController,
                          decoration: InputDecoration(
                            labelText: 'Category Name',
                          ),
                          onChanged: (value) => _categoryName = value,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter a category name'
                              : null,
                        ),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(labelText: 'Description'),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          onChanged: (value) => _description = value,
                        ),
                        TextFormField(
                          controller: _iconController,
                          decoration: InputDecoration(
                            labelText: 'Icon',
                            hint: Text('Icon'),
                            prefixIcon: ValueListenableBuilder(
                              valueListenable: _icon,
                              builder: (context, value, child) {
                                return Icon(
                                  IconData(
                                    value,
                                    fontFamily: Icons.category.fontFamily,
                                  ),
                                  color: _pickerColor,
                                );
                              },
                            ),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final pickedIcon = await showIconPicker(
                              context,
                              configuration: SinglePickerConfiguration(
                                iconColor: _pickerColor,
                                iconPackModes: [IconPack.material],
                              ),
                            );
                            setState(() {
                              if (pickedIcon == null) return;
                              _icon.value = pickedIcon.data.codePoint;
                            });
                          },
                        ),
                        TextFormField(
                          controller: _colorController,
                          decoration: InputDecoration(
                            labelText: 'Color',
                            prefixIcon: Icon(Icons.circle, color: _pickerColor),
                          ),
                          readOnly: true,
                          onTap: () => showColorPicker(context, () {
                            final hex = Utils.colorToHex(
                              _pickerColor,
                              includeHashSign: true,
                              enableAlpha: false,
                              toUpperCase: false,
                            );
                            setState(() {
                              // _color = hex;
                              _colorController.text = hex;
                              _pickerColor = Utils.hexStringToColor(hex);
                            });
                            debugPrint(
                              'Selected color: ${_pickerColor.toString()}',
                            );
                            Navigator.of(context).pop();
                          }),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: ElevatedButton.icon(
                    key: const Key('saveCategoryButton'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: widget.foregroundColor,
                      backgroundColor: widget.backgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      minimumSize: Size(double.infinity, 48),
                    ),
                    onPressed: () {
                      final loaderOverlay = context.loaderOverlay;

                      if (!_formKey.currentState!.validate()) {
                        messager.showSnackBar(
                          SnackBar(
                            content: Text('Please fill in all fields'),
                            backgroundColor: Colors.red.shade400,
                          ),
                        );
                      }

                      loaderOverlay.show();
                      save(context)
                          .then((_) {
                            messager.showSnackBar(
                              SnackBar(
                                content: Text('Category saved successfully!'),
                                backgroundColor: Colors.green.shade400,
                              ),
                            );

                            navigator.pop();
                            onClosed();
                          })
                          .catchError((error) {
                            messager.showSnackBar(
                              SnackBar(
                                content: Text('Error saving category: $error'),
                                backgroundColor: Colors.red.shade400,
                              ),
                            );
                          })
                          .whenComplete(() => loaderOverlay.hide());

                      return;
                    },
                    icon: const Icon(Icons.save),
                    label: Text('Save'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> save(BuildContext context) async {
    final api = ApiCategory(context);
    final payload = SaveCategory(
      id: widget.itemId,
      name: _categoryName ?? '',
      description: _description,
      icon: _icon.value,
      color: _colorController.text,
    );

    await api.saveCategory(payload: payload);
  }

  Future<void> showColorPicker(
    BuildContext context,
    VoidCallback onColorSelected,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              enableAlpha: false,
              pickerColor: _pickerColor,
              onColorChanged: (color) => _pickerColor = color,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                onColorSelected();
              },
            ),
          ],
        );
      },
    );
  }

  void onClosed() {
    if (widget.onClosed == null) return;
    widget.onClosed!.call();
  }

  @override
  void dispose() {
    _icon.dispose();
    _categoryNameController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    _iconController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }
}
