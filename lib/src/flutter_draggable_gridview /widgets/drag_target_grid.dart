part of draggable_grid_view;

class DragTargetGrid extends ConsumerStatefulWidget {
  final int index;
  final VoidCallback voidCallback;
  final Widget? feedback;
  final Widget? childWhenDragging;
  final PlaceHolderWidget? placeHolder;
  final DragCompletion dragCompletion;
  final bool? showChecks;
  const DragTargetGrid({
    Key? key,
    required this.index,
    required this.voidCallback,
    this.feedback,
    this.childWhenDragging,
    this.placeHolder,
    required this.dragCompletion,
    this.showChecks = false,
  }) : super(key: key);

  @override
  _DragTargetGridState createState() => _DragTargetGridState();
}

class _DragTargetGridState extends ConsumerState<DragTargetGrid> {
  @override
  Widget build(BuildContext context) {
    ref.watch(dragItemListProvider);
    return DragTarget(
      onAccept: (data) => setState(() {
        onDragComplete(widget.index);
      }),
      onLeave: (details) {
        // print('onLeave: $details');
      },
      onWillAccept: (details) {
        return true;
      },
      onMove: (details) {
        setState(() {
          setDragStartedData(details, widget.index);
          checkIndexesAreSame(details, widget.index);
          widget.voidCallback();
        });
      },
      builder: (
        BuildContext context,
        List<dynamic> accepted,
        List<dynamic> rejected,
      ) {
        /// [isOnlyLongPress] is true then set the 'LongPressDraggableGridView' class or else set 'PressDraggableGridView' class.
        return (_isOnlyLongPress)
            ? LongPressDraggableGridView(
                index: widget.index,
                feedback: widget.feedback,
                childWhenDragging: widget.childWhenDragging,
              )
            : PressDraggableGridView(
                index: widget.index,
                feedback: widget.feedback,
                childWhenDragging: widget.childWhenDragging,
                onDragCancelled: () {
                  onDragComplete(_lastIndex);
                },
                onSelected: () {
                  setState(() {});
                  ref.read(dragItemListProvider.notifier).notify();
                },
              );
      },
    );
  }

  void setDragStartedData(DragTargetDetails details, int index) {
    if (_dragStarted) {
      _dragStarted = false;
      _draggedIndexRemoved = false;
      _draggedIndex = details.data;
      _draggedChild = const EmptyItem();
      _lastIndex = _draggedIndex;
    }
  }

  void checkIndexesAreSame(DragTargetDetails details, int index) {
    if (_draggedIndex != -1 && index != _lastIndex) {
      _list.removeWhere((element) {
        return (widget.placeHolder != null)
            ? element is PlaceHolderWidget
            : element is EmptyItem;
      });
      _lastIndex = index;

      if (_draggedIndex > _lastIndex) {
        _draggedChild = _orgList[_draggedIndex - 1];
      } else {
        _draggedChild = _orgList[(_draggedIndex + 1 >= _list.length)
            ? _draggedIndex
            : _draggedIndex + 1];
      }
      if (_draggedIndex == _lastIndex) {
        _draggedChild = widget.placeHolder ?? const EmptyItem();
      }
      if (!_draggedIndexRemoved) {
        _draggedIndexRemoved = true;
        _list.removeAt(_draggedIndex);
      }
      _list.insert(
        _lastIndex,
        widget.placeHolder ?? const EmptyItem(),
      );
    }
  }

  void onDragComplete(int index) {
    final _temp = _listItems[index];
    final _target = _listItems[_draggedIndex];
    _listItems[index] = DragItem(
      value: _target.value,
      index: _draggedIndex,
      order: _target.order,
      selected: _target.selected,
      widget: _target.widget,
    );
    _listItems[_draggedIndex] = DragItem(
      value: _temp.value,
      index: index,
      order: _temp.order,
      selected: _temp.selected,
      widget: _temp.widget,
    );

    _list.removeAt(index);
    _listItems.removeAt(index);
    // _templist.insert(_draggedIndex, _draggedItem);
    // _templist.insert(index, _targetItem);
    _list.insert(
      index,
      _orgList[_draggedIndex],
    );
    _listItems.insert(
      index,
      _orgListItems[_draggedIndex],
    );

    _orgList = [..._list];
    _orgListItems = [..._listItems];
    _dragStarted = false;
    _draggedIndex = -1;
    widget.voidCallback();
    widget.dragCompletion.onDragAccept(_orgList);
    ref.read(dragItemListProvider.notifier).setAll(_listItems);
  }
}
