part of draggable_grid_view;

var _dragStarted = false;
var _dragEnded = true;
late List<Widget> _orgList;
late List<Widget> _list;
Widget? _draggedChild;
int _draggedIndex = -1;
int _lastIndex = -1;
bool _draggedIndexRemoved = false;
late List<DragItem> _orgListItems;
late List<DragItem> _listItems;
bool _showChecks = false;
List<DragItem> _listItemsSelecteds = [];
bool isSelected(DragItem item) => _listItemsSelecteds.contains(item);
void onCheckSelected(DragItem item, bool isSelected) {
  _listItemsSelecteds.remove(item);
  if (isSelected) _listItemsSelecteds.add(item);
}

/// [isOnlyLongPress] is Accepts 'true' and 'false'
/// If, it is true then only draggable works with long press.
/// and if it is false then it works with simple press.
bool _isOnlyLongPress = true;

class DragItem extends Equatable {
  final dynamic value;
  final bool selected;
  final Widget widget;
  final int index;
  final int order;
  const DragItem({
    required this.value,
    required this.selected,
    required this.widget,
    required this.index,
    required this.order,
  });
  @override
  List<Object> get props => [value, selected, widget];
}

final dragItemListProvider =
    StateNotifierProvider.autoDispose<DragItemList, List<DragItem>>((ref) {
  return DragItemList([]);
});

class DragItemList extends StateNotifier<List<DragItem>> {
  DragItemList([List<DragItem>? initialTodos]) : super(initialTodos ?? []);
  List<DragItem> get selecteds => _listItemsSelecteds;
  void setAll(List<DragItem> newList) {
    state = [...newList];
  }

  List<Widget>? get list => _list;
  void add(DragItem newItem) {
    state = [...state, newItem];
    // state = [...newList];
    _list = [
      ..._list,
      newItem.widget
    ]; // /// [orgList] will set when the drag completes.
    _orgList = [..._orgList, newItem.widget];
    _listItems = [..._listItems, newItem];
    _orgListItems = [..._orgListItems, newItem];
  }

  void removeSelecteds() {
    _showChecks = false;
    // final _tempSelecteds = _listItemsSelecteds;
    // _listItemsSelecteds.clear();
    final List<DragItem> notSelecteds = [];
    //   for (var i = 0; i < _listItems.length; i++)
    //     if (_tempSelecteds
    //         .where((element) => element.value == _listItems[i].value)
    //         .isEmpty)
    //       _listItems[i]
    // ];
    for (var item in _listItems) {
      final data =
          selecteds.firstWhereOrNull((element) => element.value == item.value);
      if (data == null) notSelecteds.add(item);
    }
    _listItemsSelecteds.clear();

    _list = [...notSelecteds.map((e) => e.widget)];
    _orgList = [..._list];
    _listItems = [...notSelecteds];
    _orgListItems = [...notSelecteds];
    state = [...notSelecteds];
    // debugPrint('$notSelecteds');
    // print(selecteds
    //     .map((e) => _listItems.where((element) => element.value == e.value))
    //     .toList());
    // _listItemsSelecteds = [
    //   for (var row in _listItemsSelecteds)
    //     if (row.selected == false) row
    // ];
    // _list = print(state);
    // state = [...state, newItem];
    //   // state = [...newList];
    //   _list = [
    //     ..._list,
    //     newItem.widget
    //   ]; // /// [orgList] will set when the drag completes.
    //   _orgList = [..._orgList, newItem.widget];
    //   _listItems = [..._listItems, newItem];
    //   _orgListItems = [..._orgListItems, newItem];

    // _listItems = [
    //   for (var row in _listItems)
    //     if (isSelected(row) == false) row
    // ];
    // // _listItems.forEach((element) {
    // //   print(isSelected(element));
    // // });
    // _orgListItems = listItems;
    // _list = [..._listItems.map((e) => e.widget)];
    // _orgList = _list;
    // // // state = [..._listItems];
    // _listItemsSelecteds.clear();
    // _showChecks = false;
    // state = [...listItems];

    // _list = [...widget.listOfWidgets.map((e) => e.widget)];
    // debugPrint('init');

    // /// [orgList] will set when the drag completes.
    // _orgList = [...widget.listOfWidgets.map((e) => e.widget)];
    // _listItems = [...widget.listOfWidgets];
    // _orgListItems = [...widget.listOfWidgets];

    // remove(_listItemsSelecteds.first);
  }

  void remove(DragItem target) {
    // state = state.where((item) => item.value != target.value).toList();
    // state = [...newList];
    _list = [...state.map((e) => e.widget)];

    /// [orgList] will set when the drag completes.
    _orgList = [...state.map((e) => e.widget)];
    _listItems = state;
    _orgListItems = state;
  }

  void notify() {
    final newState = state;
    state = [...newState];
  }

  bool get isAllSelecteds => _listItemsSelecteds.length == _listItems.length;
  bool get isCheckBoxsActive => _showChecks;
  toogleAll(bool selected) {
    _listItemsSelecteds.clear();
    if (selected) _listItemsSelecteds.addAll(_listItems);
    state = [
      for (var i = 0; i < state.length; i++)
        DragItem(
            index: i,
            order: i,
            value: state[i].value,
            selected: selected,
            widget: state[i].widget)
      // for (final row in state)
      //   DragItem(value: row.value, selected: selected, widget: row.widget)
    ];
    // debugPrint('${_listItemsSelecteds.length} == ${state.length} ');
  }

  toogleCheckboxs() {
    _showChecks = !_showChecks;
    final _state = state;

    if (!_showChecks) {
      _listItemsSelecteds = [];
      state = [
        for (var i = 0; i < state.length; i++)
          DragItem(
              index: i,
              order: i,
              value: state[i].value,
              selected: false,
              widget: state[i].widget)
        // for (final row in state)
        //   DragItem(value: row.value, selected: false, widget: row.widget)
      ];
    } else {
      state = [..._state];
    }
  }

  bool isSelected(DragItem item) => _listItemsSelecteds.contains(item);
  List<DragItem> get listItemsSelecteds => _listItemsSelecteds;
  List<DragItem> get listItems => _listItems;
  void toggle(DragItem item) {
    _listItemsSelecteds.remove(item);
    if (item.selected) _listItemsSelecteds.add(item);
    state = [
      for (var i = 0; i < state.length; i++)
        if (state[i] == item)
          DragItem(
              index: i,
              order: i,
              value: state[i].value,
              selected: !state[i].selected,
              widget: state[i].widget)
        // for (final todo in state)
        //   if (todo == item)
        //     DragItem(
        //         value: todo.value, selected: !todo.selected, widget: todo.widget)
        else
          item,
    ];
  }
}
