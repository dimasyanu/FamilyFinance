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
  Color pickerColor = Color.fromARGB(255, 255, 255, 255);

  final _formKey = GlobalKey<FormState>();

  final _categotyName = ValueNotifier<String>('');
  final _description = ValueNotifier<String>('');
  final _color = ValueNotifier<String>('');
  final _icon = ValueNotifier<int>(0);

  final _colorController = TextEditingController();
  final _categoryNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _iconController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.isNew) {
      _color.value = '#000000'; // Default color for new category
      pickerColor = Utils.hexStringToColor(_color.value);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        loadCategoryData(context);
      });
    }
  }

  Future<void> loadCategoryData(BuildContext context) async {
    final api = ApiCategory(context);
    final loaderOverlay = context.loaderOverlay;
    final messager = ScaffoldMessenger.of(context);
    loaderOverlay.show();
    try {
      final response = await api.getCategoryById(categoryId: widget.itemId!);

      if (response.hasError) {
        throw Exception('Failed to load category: ${response.message}');
      }
      setState(() {
        _categotyName.value = response.data?.name ?? '';
        _description.value = response.data?.description ?? '';
        _color.value = response.data?.color ?? '';
        _icon.value = response.data?.icon ?? 0;

        _categoryNameController.text = _categotyName.value;
        _descriptionController.text = _description.value;
        pickerColor = Utils.hexStringToColor(_color.value);
        _colorController.text = _color.value;
      });
    } catch (error) {
      messager.showSnackBar(
        SnackBar(
          content: Text('Error loading category: $error'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      loaderOverlay.hide();
    }
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
      body: Container(
        padding: sizeUtil.dynamicPadding(
          maxXPercentage: .1,
          maxYPercentage: .04,
        ),
        child: Column(
          children: <Widget>[
            Center(
              child: Form(
                key: _formKey,
                child: Column(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      controller: _categoryNameController,
                      decoration: InputDecoration(labelText: 'Category Name'),
                      onChanged: (value) => _categotyName.value = value,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter a category name'
                          : null,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      onChanged: (value) => _description.value = value,
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
                              color: pickerColor,
                            );
                          },
                        ),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final pickedIcon = await showIconPicker(
                          context,
                          configuration: SinglePickerConfiguration(
                            iconColor: pickerColor,
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
                        prefixIcon: Icon(Icons.circle, color: pickerColor),
                      ),
                      readOnly: true,
                      onTap: () => showColorPicker(context),
                    ),
                  ],
                ),
              ),
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
    );
  }

  Future<void> save(BuildContext context) async {
    final api = ApiCategory(context);
    final payload = SaveCategory(
      id: widget.itemId,
      name: _categotyName.value,
      description: _description.value,
      icon: _icon.value,
      color: _color.value,
    );

    await api.saveCategory(payload: payload);
  }

  void changeColor(Color color) {
    setState(() {
      pickerColor = color;
    });
  }

  Future<void> showColorPicker(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              enableAlpha: false,
              pickerColor: pickerColor,
              onColorChanged: changeColor,
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
                setState(() {
                  final hex = Utils.colorToHex(
                    pickerColor,
                    includeHashSign: true,
                    enableAlpha: false,
                    toUpperCase: false,
                  );
                  _color.value = hex;
                  debugPrint('Selected hex color: $hex');
                  _colorController.text = _color.value;
                });
                Navigator.of(context).pop();
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
    _categotyName.dispose();
    _description.dispose();
    _color.dispose();
    _icon.dispose();
    _categoryNameController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    _iconController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }
}
