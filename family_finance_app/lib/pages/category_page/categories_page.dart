import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/components/bottom_action_menu.dart';
import 'package:family_financial_app/components/row_action.dart';
import 'package:family_financial_app/models/mypage.dart';
import 'package:family_financial_app/models/responses/item_category.dart';
import 'package:family_financial_app/pages/category_page/categories_detail.dart';
import 'package:family_financial_app/pages/category_page/categories_form_page.dart';
import 'package:family_financial_app/pages/category_page/categories_table_source.dart';
import 'package:family_financial_app/plugins/api_category.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart'
    hide RefreshIndicatorState;

class CategoriesPage extends MyPage {
  final ApiCategory api;
  final Store store;
  final ScaffoldMessengerState messenger;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  final categories = ValueNotifier<List<ItemCategory>>([]);
  final totalCount = ValueNotifier<int>(0);
  final pageSize = ValueNotifier<int>(10);
  final page = ValueNotifier<int>(1);
  final isError = ValueNotifier<bool>(false);
  final refreshController = RefreshController(initialRefresh: false);

  static const headerStyle = TextStyle(fontWeight: FontWeight.bold);

  final List<DataColumn> columns = const [
    DataColumn(
      label: Row(
        children: [
          SizedBox(width: 16.0),
          Text('Name', style: headerStyle),
        ],
      ),
    ),
    DataColumn(label: Text('Description', style: headerStyle)),
    DataColumn(label: Text('Created At', style: headerStyle)),
    DataColumn(label: Text('Created by', style: headerStyle)),
  ];

  CategoriesPage(super.context)
    : store = context.read<Store>(),
      messenger = ScaffoldMessenger.of(context),
      api = ApiCategory(context),
      super(route: 'CategoriesPage', title: 'Categories');

  @override
  Color? appBarForegroundColor() {
    return Colors.white;
  }

  @override
  Color? appBarBackgroundColor() {
    return Colors.orange;
  }

  @override
  Widget? appBarTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      key: const Key('appBarTitle'),
      children: [
        Icon(Icons.category, color: appBarForegroundColor()),
        const SizedBox(width: 10.0),
        Text(
          title,
          style: TextStyle(color: appBarForegroundColor(), fontSize: 18),
        ),
      ],
    );
  }

  @override
  Future<void> onMounted(BuildContext context) async {
    await refreshController.requestRefresh();
  }

  @override
  Widget build(BuildContext context) {
    _refreshKey.currentState?.show();
    final navigator = Navigator.of(context);
    return SmartRefresher(
      key: _refreshKey,
      controller: refreshController,
      enablePullDown: true,
      header: WaterDropMaterialHeader(
        backgroundColor: appBarBackgroundColor(),
        color: Colors.white,
        distance: 80.0,
      ),
      onRefresh: () async {
        await loadTable(context);
        refreshController.refreshCompleted();
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: PaginatedDataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
            columns: columns,
            showEmptyRows: false,
            source: CategoriesTableSource(
              context: context,
              categories: categories.value,
              onRowLongPressed: (category) => showModalBottomSheet(
                context: context,
                builder: (context) {
                  return BottomActionMenu(
                    itemDetail: CategoriesDetail(category: category),
                    actions: [
                      RowAction(
                        icon: Icon(Icons.close, color: Colors.grey),
                        label: 'Cancel',
                        onPressed: () {
                          navigator.pop(); // Close the bottom sheet
                        },
                      ),
                      RowAction(
                        icon: Icon(Icons.edit),
                        label: 'Edit',
                        backgroundColor: Colors.blue.shade50,
                        onPressed: () {
                          navigator.pop();
                          navigator.push(
                            MaterialPageRoute(
                              builder: (context) => CategoriesFormPage(
                                itemId: category.id,
                                onClosed: () {
                                  refreshController.requestRefresh();
                                },
                                backgroundColor: appBarBackgroundColor()!,
                                foregroundColor: appBarForegroundColor()!,
                              ),
                            ),
                          );
                        },
                      ),
                      RowAction(
                        icon: Icon(Icons.delete, color: Colors.red.shade300),
                        label: 'Delete',
                        backgroundColor: Colors.red.shade50,
                        onPressed: () {
                          showDeleteConfirmationDialog(context, category);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Load the categories table or any necessary data.
  Future<void> loadTable(BuildContext context) async {
    final user = store.getUser();
    if (user == null) throw Exception('User not logged in');
    try {
      final response = await api.getCategories(
        page: page.value,
        pageSize: pageSize.value,
      );
      if (response.success) {
        setState(() {
          isError.value = false;
          categories.value = response.data?.items ?? [];
          totalCount.value = response.data?.totalCount ?? 0;
        });
      } else {
        isError.value = true;
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to load categories'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } catch (error) {
      isError.value = true;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to load categories'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  Future<void> deleteItem(
    String userId,
    String categoryId,
    ScaffoldMessengerState messenger,
    NavigatorState navigator,
    VoidCallback loadTable,
  ) async {
    refreshController.requestLoading();
    try {
      final response = await api.deleteCategory(categoryId: categoryId);
      if (response.success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Category deleted successfully'),
            backgroundColor: Colors.green.shade400,
          ),
        );
        navigator.pop(); // Close the dialog
        () => loadTable(); // Refresh the table after deletion
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to delete category'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to delete category'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      refreshController.refreshCompleted();
      loadTable();
      navigator.pop();
    }
  }

  void showDeleteConfirmationDialog(
    BuildContext context,
    ItemCategory category,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final navigator = Navigator.of(context);
        return AlertDialog(
          title: Text('Delete Category'),
          content: Text(
            'Are you sure you want to delete this category?\n${category.name}',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                navigator.pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                await deleteItem(
                  store.getUser()?.userId ?? '',
                  category.id,
                  messenger,
                  navigator,
                  () => refreshController.requestRefresh(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  FloatingActionButton? floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      key: const Key('addCategoryButton'),
      onPressed: () {
        // Navigate to the add category page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoriesFormPage(
              backgroundColor: appBarBackgroundColor()!,
              foregroundColor: appBarForegroundColor()!,
              onClosed: () {
                refreshController.requestRefresh();
              },
            ),
          ),
        );
      },
      shape: CircleBorder(),
      backgroundColor: appBarBackgroundColor(),
      foregroundColor: appBarForegroundColor(),
      child: const Icon(Icons.add),
    );
  }

  @override
  void dispose() {
    categories.dispose();
    totalCount.dispose();
    pageSize.dispose();
    page.dispose();
    isError.dispose();
    super.dispose();
  }
}
