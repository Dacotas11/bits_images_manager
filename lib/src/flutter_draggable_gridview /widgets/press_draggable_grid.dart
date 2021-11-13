part of draggable_grid_view;

class PressDraggableGridView extends StatelessWidget {
  final int index;
  final Widget? feedback;
  final Widget? childWhenDragging;
  final VoidCallback onDragCancelled;
  final VoidCallback onSelected;
  const PressDraggableGridView({
    Key? key,
    required this.index,
    this.feedback,
    this.childWhenDragging,
    required this.onDragCancelled,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var gridTile = GridTile(
        header: _showChecks
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 30,
                    child: Column(
                      children: [
                        const Spacer(
                          flex: 2,
                        ),
                        Container(
                          alignment: Alignment.bottomRight,
                          width: 14,
                          height: 14,
                          color: Colors.white,
                          child: Checkbox(
                            value: isSelected(_listItems[index]),
                            onChanged: (bool? value) {
                              onCheckSelected(_listItems[index], value!);
                              onSelected();
                              // ref
                              //     .watch(drapItemListProvider.notifier)
                              //     .toggle(_listItems[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  )
                ],
              )
            : null,
        child: _list[index]);
    return !_showChecks
        ? Draggable(
            onDraggableCanceled: (velocity, offset) {
              onDragCancelled();
            },
            onDragStarted: () {
              if (_dragEnded) {
                _dragStarted = true;
                _dragEnded = false;
              }
            },
            onDragEnd: (details) {
              _dragEnded = true;
              _dragStarted = false;
            },
            data: index,
            feedback: feedback ?? _list[index],
            child: gridTile,
            // child: GridTile(

            //   child: _list[index],
            //   footer: index == 0
            //       ? GridTileBar(
            //           // backgroundColor: Colors.black87,
            //           // color: Theme.of(context).primaryColor,
            //           title: Container(
            //               height: 20,
            //               alignment: Alignment.center,
            //               color: Theme.of(context).primaryColor,
            //               child: const Text("Principal")),
            //         )
            //       : null,
            // ),
            childWhenDragging: (childWhenDragging != null)
                ? childWhenDragging
                : (_draggedChild != null)
                    ? _draggedChild
                    : _list[index],
          )
        : gridTile;
  }
}
