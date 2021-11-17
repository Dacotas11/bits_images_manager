import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dotted_border/dotted_border.dart';
import 'package:equatable/equatable.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:bits_images_manager/src/_utils/device_info.dart';
import 'package:bits_images_manager/src/_utils/imagesutils.dart';
import 'package:bits_images_manager/src/asyncvaluewidget.dart';
import 'package:bits_images_manager/src/pick_images_command.dart';

// import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
// import 'package:reorderable_grid/reorderable_grid.dart';

import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import 'flutter_draggable_gridview /flutter_draggable_gridview.dart';
import 'image_picker/image_picker.dart';

// import 'package:bits/src/common_widgets/asyncvaluewidget.dart';
// import 'package:bits/src/common_widgets/flutter_draggable_gridview%20/flutter_draggable_gridview.dart';

class ImagelistContainer extends HookConsumerWidget {
  const ImagelistContainer({
    Key? key,
    required this.onData,
    required this.postUrl,
  }) : super(key: key);
  final void Function(List<String>) onData;
  final String postUrl;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesList = ref.watch(urlListProvider);
    final controller = useScrollController();
    // final GlobalKey<ExpandableBottomSheetState> _bottomkey =
    //     useMemoized(() => GlobalKey());
    // final _onSubmit = useMemoized(
    //   () => () {
    //     _bottomkey.currentState!.expand();
    //   },
    //   [_bottomkey],
    // );
    return imagesList.isNotEmpty
        ? Scrollbar(
            controller: controller,
            child: Container(
                // height: 150,
                child: ListView.builder(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: imagesList.length,
                    itemBuilder: (ctx, i) {
                      if (i == imagesList.length - 1) {
                        return InkWell(
                          onDoubleTap: () {
                            openPhotoVieweDialog(context, imagesList);
                          },
                          onTap: () {
                            showPicker(context);
                          },
                          child: Row(
                            children: [
                              ProviderScope(
                                overrides: [
                                  _currentUrl.overrideWithValue(imagesList[i]),
                                ],
                                child: Container(
                                  // height: 150,
                                  child: ImageItem(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: DottedBorder(
                                    child: Center(
                                      child: Icon(
                                        Icons.add_circle,
                                        size: 50,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return InkWell(
                          onDoubleTap: () {
                            openPhotoVieweDialog(context, imagesList);
                          },
                          onTap: () async {
                            // Navigator.of(context).push(MaterialPageRoute<void>(
                            //     builder: (BuildContext context) {
                            //       return const SelectedsImagesView();
                            //     },
                            //     fullscreenDialog: true));
                            showPicker(context);
                          },
                          child: ProviderScope(
                            overrides: [
                              _currentUrl.overrideWithValue(imagesList[i]),
                            ],
                            child: Container(
                              // height: 150,
                              child: ImageItem(),
                            ),
                          ),
                        );
                      }
                    })),
          )
        : InkWell(
            onDoubleTap: () {
              openPhotoVieweDialog(context, imagesList);
            },
            onTap: () {
              // showModalBottomSheet(
              //   context: context,
              //   isScrollControlled: true,
              //   // backgroundColor: PhotoboothColors.transparent,
              //   builder: (_) => const SelectedsImagesView(),
              // );
              Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return SelectedsImagesView(
                      postUrl: postUrl,
                    );
                  },
                  fullscreenDialog: true));
            },
            child: DottedBorder(
              child: Center(
                child: Icon(
                  Icons.add_circle,
                  size: 50,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          );
  }

  void openPhotoVieweDialog(BuildContext context, List<String> urlImages) =>
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return GalleryPhotoViewWrapper(
            imagesUrl: urlImages,
          );
        },
      );
  void showPicker(BuildContext context) async {
    var result = DeviceOS.isDesktopOrWeb
        ? await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                  // shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  child: SizedBox(
                      width: 400,
                      height: 500,
                      child: SelectedsImagesView(
                        postUrl: postUrl,
                      )));
            })
        : Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return SelectedsImagesView(
                postUrl: postUrl,
              );
            },
            fullscreenDialog: true));
    // onData(result);
  }
}

class DragCompletionStringListResponse extends StatelessWidget
    implements DragCompletion {
  const DragCompletionStringListResponse({Key? key, required this.onDrag})
      : super(key: key);
  final ValueChanged<List<String>> onDrag;
  @override
  void onDragAccept(List<Widget> list) {
    final i = list
        .map((e) => ((((e as SizedBox).child as Padding).child as GridTile)
                .child as ImageItem)
            .url!)
        .toList();
    onDrag(i);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class SelectedsImagesView extends ConsumerStatefulWidget {
  const SelectedsImagesView({Key? key, required this.postUrl})
      : super(key: key);
  final String postUrl;
  @override
  _SelectedsImagesView createState() => _SelectedsImagesView();
}

class _SelectedsImagesView extends ConsumerState<SelectedsImagesView>
    with DragFeedback, DragPlaceHolder, DragCompletion {
  // DragCompletion dragCompletion(List<Widget> list ){};

  int variableSet = 0;
  double? width;
  double? height;

  @override
  Widget build(BuildContext context) {
    final imagesList = ref.watch(urlListProvider);

    // debugPrint('NEW ${imagesList.first}');

    final list = List.generate(imagesList.length, (i) {
      final _url = imagesList[i];

      // print('nuevo $_url');
      // final imageItem = ImageItem(
      //   url: _url,
      // );

      return DragItem(
        index: i,
        order: i,
        value: _url,
        selected: false,
        widget: SizedBox(
          // padding: const EdgeInsets
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: ProviderScope(
              overrides: [
                _currentUrl.overrideWithValue(imagesList[i]),
              ],
              child: ImageItem(
                url: _url,
              ),
            ),
          ),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 1
        elevation: 0,

        actions: [
          TextButton(
              onPressed: () {
                final result = ref
                    .read(dragItemListProvider.notifier)
                    .listItems
                    .map((e) => e.value.toString())
                    .toList();

                ref.read(urlListProvider.notifier).setNewList(result);
                Navigator.of(context, rootNavigator: true).pop(result);
              },
              child: const Text('Close'))
        ],
        title: HookConsumer(builder: (context, ref, child) {
          final items =
              ref.read(dragItemListProvider.notifier).listItems.length;
          return Text(
            '$items  Items',
            style: const TextStyle(
              color: Colors.black, // 3
            ),
          );
        }),
      ),
      body: dragableGrid(list),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: HookConsumer(builder: (context, ref, child) {
        ref.watch(dragItemListProvider);
        final notifier = ref.read(dragItemListProvider.notifier);
        return !notifier.isCheckBoxsActive
            ? DeviceOS.isDesktopOrWeb
                ? FloatingActionButton(
                    onPressed: () async {
                      try {
                        final images = await PickImagesCommand()
                            .run(allowMultiple: true, enableCamera: false);
                        final urList = await ref
                            .read(imageStorageProvider)
                            .uploadImage(images.map((e) => e.path!).toList(),
                                '', widget.postUrl);
                        // print(urList);
                        // ref.read(urlListProvider.notifier).add(a);
                        int index = notifier.listItems.length;

                        for (var url in urList) {
                          ref.read(dragItemListProvider.notifier).add(DragItem(
                                index: index,
                                order: index,
                                value: url,
                                selected: false,
                                widget: SizedBox(
                                  // padding: const EdgeInsets
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: ProviderScope(
                                      overrides: [
                                        _currentUrl.overrideWithValue(url),
                                      ],
                                      child: ImageItem(
                                        url: url,
                                      ),
                                    ),
                                  ),
                                ),
                              ));
                        }
                        setState(() {});
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: const Icon(Icons.add),
                  )
                : (FloatingActionButton(
                    child: const Icon(Icons.add),
                    onPressed: () async {
                      final permitted = await PhotoManager.requestPermission();
                      if (!permitted) return;
                      showModalBottomSheet(
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20.0))),
                          backgroundColor: Colors.white,
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              child: RecentsPhotosPage(
                                postUrl: widget.postUrl,
                              ))).whenComplete(() => setState(() {}));
                    }))
            : const SizedBox();
      }),
      bottomNavigationBar: HookConsumer(builder: (context, ref, child) {
        ref.watch(dragItemListProvider);
        final notifier = ref.read(dragItemListProvider.notifier);
        final onSelecting = notifier.isCheckBoxsActive;
        return BottomAppBar(
            // shape: const CircularNotchedRectangle(),
            child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (onSelecting) ...[
                Row(
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                        onPressed: () {
                          ref
                              .read(dragItemListProvider.notifier)
                              .toogleAll(!notifier.isAllSelecteds);
                        },
                        child: notifier.isAllSelecteds
                            ? const Text('Deselect all')
                            : const Text('Select all')),
                    if (notifier.selecteds.isNotEmpty)
                      ElevatedButton(
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        onPressed: () {
                          ref
                              .read(dragItemListProvider.notifier)
                              .removeSelecteds();
                          setState(() {});
                        },
                        child: Text('Delete ( ${notifier.selecteds.length} )'),
                      )
                  ],
                ),
              ],
              // TextButton(onPressed: () {}, child: const SizedBox()),
              const SizedBox(width: 40),
              TextButton(
                  onPressed: () {
                    ref.read(dragItemListProvider.notifier).toogleCheckboxs();
                  },
                  child: !onSelecting
                      ? const Text('Select')
                      : const Text('Cancel'))
            ],
          ),
        ));
      }),
    );
  }

  DraggableGridViewBuilder dragableGrid(List<DragItem> list) {
    return DraggableGridViewBuilder(
      isOnlyLongPress: false,
      dragFeedback: this,
      dragPlaceHolder: this,
      showChecks: false,
      // dragChildWhenDragging: this,
      // itemCount: imagesList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
      ),

      listOfWidgets: list,
      dragCompletion: this,
      // dragCompletion: DragCompletionStringListResponse(
      //   onDrag: (List<String> newList) {
      //     ref.read(urlListProvider.notifier).setNewList(newList);
      //   },
      // ),
    );
  }

//  DraggableGridViewBuilder newMethod(List<SizedBox> list, WidgetRef ref) {
//     return DraggableGridViewBuilder(
//       addAutomaticKeepAlives: false,
//       isOnlyLongPress: false,
//       dragFeedback: this,
//       dragPlaceHolder: this,
//       // dragChildWhenDragging: this,
//       // itemCount: imagesList.length,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 1.8,
//       ),

//       listOfWidgets: list,
//       dragCompletion: DragCompletionStringListResponse(
//         onDrag: (List<String> newList) {
//           ref.read(urlListProvider.notifier).setNewList(newList);
//         },
//       ),
//     );
//   }

  @override
  Widget feedback(List<Widget> list, int index) {
    var item = list[index] as SizedBox;

    return SizedBox(
      child: item.child,
      width: 200,
      height: 150,
    );
  }

  @override
  PlaceHolderWidget placeHolder(List<Widget> list, int index) {
    return PlaceHolderWidget(
      child: Container(
        color: Colors.white,
      ),
    );
  }

  @override
  void onDragAccept(list) {
    // final i = list
    //     .map((e) =>
    //         (((((e as SizedBox).child as ProviderScope).child as Padding).child
    //                     as GridTile)
    //                 .child as ImageItem)
    //             .url)
    //     .toList();

//  ref.
  }
}

class ImageListBottomSheet extends ConsumerWidget {
  const ImageListBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: const [Text('Dios es Amor')],
    );
  }
}

// CustomScrollView(
//         DragAndDropGridView(
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             childAspectRatio: 1.8,
//           ),
//             itemBuilder: (c, i) {
//             return ProviderScope(
//               overrides: [
//                 _currentUrl.overrideWithValue(imagesList[i]),
//               ],
//               child: const Padding(
//                 padding: EdgeInsets.all(4.0),
//                 child: ImageItem(),
//               ),
//             );
//           }, itemCount: imagesList.length),
//         ),

class UrlList extends StateNotifier<List<String>> {
  UrlList(List<String> state) : super(state);
  List<String> get currentList => state;
  void add(String newString) {
    state = [...state, newString];
  }

  void setNewList(List<String> newList) {
    state = newList;
  }

  void reorderList(List<String> newList) {
    state = newList;
  }
}

final urlListProvider = StateNotifierProvider<UrlList, List<String>>((ref) {
  return UrlList([
    // 'https://picsum.photos/500/300?random=1',
    // 'https://picsum.photos/500/300?random=2',
    // 'https://picsum.photos/500/300?random=3',
    // 'https://picsum.photos/500/300?random=4'
  ]);
});

final _currentUrl = Provider<String>((ref) => throw UnimplementedError());

class ImageItem extends HookConsumerWidget {
  const ImageItem({Key? key, this.url}) : super(key: key);
  final String? url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _url = ref.watch(_currentUrl);
    // final editorKey = useMemoized(() =>  GlobalKey<ExtendedImageEditorState>();
    // final imagesList = ref.read(urlListProvider.notifier).currentList;
    // final isFirst = true;
    // return ExtendedImage.network(
    //   _url,
    //   fit: BoxFit.contain,
    //   mode: ExtendedImageMode.editor,
    //   extendedImageEditorKey: editorKey,
    //   initEditorConfigHandler: (state) {
    //     return EditorConfig(
    //         maxScale: 8.0,
    //         cropRectPadding: const EdgeInsets.all(20.0),
    //         hitTestSize: 20.0,
    //         cropAspectRatio: CropAspectRatios.ratio4_3);
    //   },
    // );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: ExtendedImage.network(
        _url,

        width: 100,
        height: 100,
        fit: BoxFit.cover,
        cache: true,
        // border: Border.all(color: Colors.red, width: 1.0),
        shape: BoxShape.rectangle,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        //cancelToken: cancellationToken,
      ),
    );
    // // // debugPrint('RECEADO $_url ${imagesList} ');
    // return Padding(
    //   padding: const EdgeInsets.symmetric(horizontal: 4.0),
    //   child: ClipRRect(
    //     borderRadius: BorderRadius.circular(20),
    //     child: FancyShimmerImage(
    //       boxFit: BoxFit.cover,
    //       width: 100,
    //       height: 100,
    //       imageUrl: _url,
    //     ),
    //   ),
    // );
  }
}

class Task {
  String name;
  String description;
  String dueDate;
  String notes;
  Task({
    required this.name,
    required this.description,
    required this.dueDate,
    required this.notes,
  });
}

class CropAspectRatios {
  /// no aspect ratio for crop
  static const double? custom = null;

  /// the same as aspect ratio of image
  /// [cropAspectRatio] is not more than 0.0, it's original
  static const double original = 0.0;

  /// ratio of width and height is 1 : 1
  static const double ratio1_1 = 1.0;

  /// ratio of width and height is 3 : 4
  static const double ratio3_4 = 3.0 / 4.0;

  /// ratio of width and height is 4 : 3
  static const double ratio4_3 = 4.0 / 3.0;

  /// ratio of width and height is 9 : 16
  static const double ratio9_16 = 9.0 / 16.0;

  /// ratio of width and height is 16 : 9
  static const double ratio16_9 = 16.0 / 9.0;
}

class RecentsPhotosPage extends StatelessWidget {
  const RecentsPhotosPage({
    Key? key,
    required this.postUrl,
  }) : super(key: key);
  final String postUrl;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.95,
        child: Column(
          children: <Widget>[
            const Center(child: Icon(Icons.drag_handle)),
            Row(
              // mainAxisSize: MainAxisSize.min,
              children: const <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      bottom: 8.0, top: 24, left: 16, right: 16),
                  child: Text(
                    "Imagenes Recientes",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

//  PickMethod().camera(
//                       maxAssetsCount: 20,
//                       handleResult:
//                           (BuildContext context, AssetEntity result) =>
//                               Navigator.of(context).pop(<AssetEntity>[result])),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: const Icon(
                          Icons.photo_camera,
                        ),
                        onPressed: () async {
                          final AssetEntity? result =
                              await CameraPicker.pickFromCamera(
                            context,
                            textDelegate: EnglishCameraPickerTextDelegate(),
                            enableRecording: true,
                          );
                          if (result != null) {
                            // print(result);
                            //
                          }
                        }),
                    IconButton(
                      icon: const Icon(
                        Icons.collections_outlined,
                      ),
                      onPressed: () async {
                        await AssetPicker.pickAssets(context,
                            themeColor: Theme.of(context).primaryColor,
                            textDelegate: EnglishTextDelegate(),
                            requestType: RequestType.common,
                            specialItemPosition: SpecialItemPosition.prepend,
                            specialItemBuilder: (BuildContext context) {
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              final AssetEntity? result =
                                  await CameraPicker.pickFromCamera(
                                context,
                                textDelegate: EnglishCameraPickerTextDelegate(),
                                enableRecording: true,
                              );
                              if (result != null) {
                                // print(result);
                                // handleResult(context, result);
                              }
                            },
                            child: const Center(
                              child: Icon(Icons.camera_enhance, size: 42.0),
                            ),
                          );
                        });

                        // print(selectedImages!.first.thumbData);
                        // List<PickedImage> images = await PickImagesCommand()
                        //     .run(allowMultiple: true, enableCamera: false);
                      },
                    )
                    // child: Text('PTHOTO')),
                  ],
                ),
                Consumer(builder: (context, ref, child) {
                  return ElevatedButton(
                      onPressed: () async {
                        Alert(
                            context: context,
                            title: 'SUBIENDO IMAGENES',
                            style: const AlertStyle(
                                isButtonVisible: false,
                                isCloseButton: false,
                                isOverlayTapDismiss: false,
                                titleStyle:
                                    TextStyle(fontWeight: FontWeight.bold)),
                            content: const SizedBox(
                              height: 80,
                              child: CupertinoActivityIndicator(),
                            )).show();

                        await ref
                            .read(imageStorageProvider)
                            .uploadPhotos(postUrl);
                        Alert(context: context).dismiss();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Upload'));
                }),
              ],
            ),
            // Adding the form here
            const Expanded(child: AssetsGallery()),
          ],
        ),
      ),
    );
  }
}

class AssetsGallery extends ConsumerWidget {
  const AssetsGallery({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsValue = ref.watch(assetEntityStateNotifierProvider);
    return AsyncValueWidget<List<AssetEntity>>(
      value: assetsValue,
      data: (assets) => GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          // A grid view with 3 items per row
          crossAxisCount: 3,
        ),
        itemCount: assets.length,
        itemBuilder: (_, index) {
          return GridTile(
              child: AssetThumbnail(
            asset: assets[index],
            index: index,
          ));
        },
      ),
    );
  }
}

class AssetThumbnail extends StatelessWidget {
  final AssetEntity asset;
  final int index;
  const AssetThumbnail({Key? key, required this.asset, required this.index})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: asset.thumbData,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        final bytes = snapshot.data;
        // If we have no data, display a spinner
        if (bytes == null) return const Center(child: StyledLoadSpinner());
        return Consumer(builder: (context, ref, child) {
          final selecteds = ref.watch(selectedsIndexListProvider);
          final item =
              selecteds.firstWhereOrNull((element) => element.index == index);
          bool isSelected = item != null;

          // final orderSec =
          //     ref.read(selectedsIndexListProvider.notifier).orderSeq(index);
          return InkWell(
            onTap: () {
              // debugPrint('$index , $selected');

              ref
                  .read(selectedsIndexListProvider.notifier)
                  .onCheckSelected(index);
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                      padding: const EdgeInsets.all(4.0),

                      // ref.watch(selectedsIndexListProvider);
                      // final selected = ref
                      //     .read(selectedsIndexListProvider.notifier)
                      //     .isSelected(index);
                      child: Container(
                          decoration: isSelected
                              ? BoxDecoration(
                                  border: Border.all(
                                      width: 2,
                                      color: Theme.of(context).primaryColor),
                                )
                              : null,
                          child: Image.memory(bytes, fit: BoxFit.cover))),
                ),
                isSelected
                    ? Positioned(
                        top: 0.0,
                        right: 0.0,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 12.0,
                            child: ClipRRect(
                              child: Text('${item.order}'),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                          ),
                        ))
                    : const SizedBox(),
              ],
            ),
          );
        });
      },
    );
  }
}

final assetEntityStateNotifierProvider = StateNotifierProvider.autoDispose<
    AssetEntityStateNotifier, AsyncValue<List<AssetEntity>>>((ref) {
  return AssetEntityStateNotifier();
});

class AssetEntityStateNotifier
    extends StateNotifier<AsyncValue<List<AssetEntity>>> {
  AssetEntityStateNotifier() : super(const AsyncValue.loading()) {
    _fetchAssets();
  }
  Future<String> getFilePathByIndex(int index) async {
    final file = await state.value![index].file;
    return file!.path;
  }

  Future<void> _fetchAssets() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final albums = await PhotoManager.getAssetPathList(onlyAll: true);
      final recentAlbum = albums.first;
      // Now that we got the album, fetch all the assets it contains
      final recentAssets = await recentAlbum.getAssetListRange(
        start: 0, // start at index 0
        end: 1000000, // end at a very big index (to get all the assets)
      );
      return recentAssets;
    });
  }
}

final selectedsIndexListProvider =
    StateNotifierProvider.autoDispose<SelectedIndexList, List<OrderIndex>>(
        (ref) {
  return SelectedIndexList([]);
});

final dioProvider = Provider((ref) => dio.Dio());

class SelectedIndexList extends StateNotifier<List<OrderIndex>> {
  SelectedIndexList(List<OrderIndex> state) : super(state);

  bool isSelected(int index) =>
      state.firstWhereOrNull((element) => element.index == index) != null;
  int? orderSeq(int index) =>
      state.firstWhereOrNull((element) => element.index == index)?.order ?? 0;
  OrderIndex? getItem(int index) =>
      state.firstWhereOrNull((element) => element.index == index);

  void onCheckSelected(int index) {
    // _selectedsAsset.removeAt(index);
    // if (!isSelected(index)) {
    //   state.add(OrderIndex(index: state.length, order: state.length + 1));
    // }
    OrderIndex? item = getItem(index);
    state.remove(item);
    if (item == null) {
      state.add(OrderIndex(index: index, order: state.length + 1));
    }
    //
    //else {
    //   state.remove(item);
    // }
    var newOrder = 1;
    final List<OrderIndex> orderList = [];
    for (final row in state) {
      orderList.add(OrderIndex(index: row.index, order: newOrder));

      newOrder++;
    }
    // debugPrint('$orderList');
    // _selectedsAsset = orderList;
    state = [...orderList];
  }

  // if (!isSelected) _selectedsAsset.add(OrderIndex(index: state.length+1));
  // state = [..._selectedsAsset];
}

// void remove(int target) {
//   state = state.where((item) => item != target).toList();
// }

class OrderIndex extends Equatable {
  final int index;
  final int order;
  const OrderIndex({
    required this.index,
    required this.order,
  });
  @override
  List<Object> get props => [index, order];
}

final imageStorageProvider =
    Provider((ref) => ImageStorageRepository(ref.read));

class ImageStorageRepository {
  final Reader reader;

  ImageStorageRepository(this.reader);
  Future<List<String>> uploadImage(
      List<String> filesPath, url, String postUrl) async {
    List<String> _urlList = [];
    try {
      // var request = http.MultipartRequest(
      //     'POST', Uri.parse('http://18.119.2.47:9419/post/producto'));
      // request.files.add(await http.MultipartFile.fromPath('image', filepath));
      // var res = await request
      //     .send()
      //     .then((result) async {
      //       http.Response.fromStream(result).then((response) {
      //         if (response.statusCode == 200) {
      //           print("Uploaded! ");
      //           print('response.body ' + response.body);
      //         }

      //         return response.body;
      //       });
      //     })
      //     .catchError((err) => print('error : ' + err.toString()))
      //     .whenComplete(() {});
      List<dio.MultipartFile> files = [];
      for (var path in filesPath) {
        files.add(await dio.MultipartFile.fromFile((path)));
      }

      dio.FormData formData = dio.FormData.fromMap({
        "file": files,
      });

      final response = await dio.Dio().post(postUrl, data: formData);
      print('response data${response.data}');
      _urlList =
          response.data.toString().split(',').map((e) => e.trim()).toList();
      return _urlList;
    } catch (e) {
      // print(e.toString());
    }
    return _urlList;
  }

  Future<List<String>> uploadPhotos(String postUrl) async {
    List<String> _urlList = [];
    final assetsindexSelecteds = reader(selectedsIndexListProvider);
    var photosList = [];
    for (var i = 0; i < assetsindexSelecteds.length; i++) {
      final filePath = await reader(assetEntityStateNotifierProvider.notifier)
          .getFilePathByIndex(assetsindexSelecteds[i].index);
      photosList.add(filePath);
    }

    List<dio.MultipartFile> files = [];
    for (var path in photosList) {
      files.add(await dio.MultipartFile.fromFile(path));
    }

    final formData = dio.FormData.fromMap({'files': files});
// 'http://18.119.2.47:9419/post/producto'
    var response = await dio.Dio().post(postUrl, data: formData);
    _urlList =
        response.data.toString().split(',').map((e) => e.trim()).toList();

    for (var url in _urlList) {
      if (url != '') {
        reader(dragItemListProvider.notifier).add(DragItem(
          index: 0,
          order: 0,
          value: url,
          selected: false,
          widget: SizedBox(
            // padding: const EdgeInsets
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ProviderScope(
                overrides: [
                  _currentUrl.overrideWithValue(url),
                ],
                child: ImageItem(
                  url: url,
                ),
              ),
            ),
          ),
        ));
      }
    }

    return _urlList;
  }
}

class StyledLoadSpinner extends StatelessWidget {
  const StyledLoadSpinner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return const SizedBox(
        width: 24,
        height: 24,
        // child: CircularProgressIndicator(
        //   backgroundColor: theme.backgroundColor,
        //   valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
        // ),
        child: CupertinoActivityIndicator());
  }
}

class GalleryPhotoViewWrapper extends HookConsumerWidget {
  final List<String> imagesUrl;

  const GalleryPhotoViewWrapper({Key? key, required this.imagesUrl})
      : super(key: key);
  void openPhotoEditorDialog(BuildContext context, String url) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleImageEditor(
            url: url,
          );
        },
      );
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _currentIndex = useState(0);
    return Scaffold(
      appBar: AppBar(
        // title: const Text('ExtendedImageGesturePageView'),
        actions: [
          TextButton(
              onPressed: () {
                openPhotoEditorDialog(context, imagesUrl[_currentIndex.value]);
              },
              child: const Text('Editar'))
        ],
      ),
      body: ExtendedImageGesturePageView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imagesUrl.length,
        controller: ExtendedPageController(
          initialPage: 0,
          pageSpacing: 4,
        ),
        itemBuilder: (BuildContext context, int index) {
          var item = imagesUrl[index];
          Widget image = ExtendedImage.network(
            item,
            fit: BoxFit.contain,
            mode: ExtendedImageMode.gesture,
            initGestureConfigHandler: (ExtendedImageState state) {
              return GestureConfig(
                cacheGesture: false,
                //you must set inPageView true if you want to use ExtendedImageGesturePageView
                inPageView: true,
                initialScale: 1.0,
                maxScale: 5.0,
                animationMaxScale: 6.0,
                initialAlignment: InitialAlignment.center,
              );
            },
          );
          image = Container(
            child: image,
            padding: const EdgeInsets.all(5.0),
          );
          if (index == _currentIndex.value) {
            return Hero(
              tag: item + index.toString(),
              child: image,
            );
          } else {
            return image;
          }
        },
        onPageChanged: (int index) {
          _currentIndex.value = index;
          // rebuild.add(index);
        },
      ),
    );
  }
}

class SimpleImageEditor extends StatefulWidget {
  const SimpleImageEditor({
    Key? key,
    required this.url,
  }) : super(key: key);
  final String url;

  @override
  _SimpleImageEditorState createState() => _SimpleImageEditorState();
}

class _SimpleImageEditorState extends State<SimpleImageEditor> {
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();
  bool _cropping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ImageEditor'),
      ),
      body: ExtendedImage.network(
        widget.url,
        fit: BoxFit.contain,
        mode: ExtendedImageMode.editor,
        enableLoadState: true,
        extendedImageEditorKey: editorKey,
        cacheRawData: true,
        initEditorConfigHandler: (ExtendedImageState? state) {
          return EditorConfig(
              maxScale: 8.0,
              cropRectPadding: const EdgeInsets.all(20.0),
              hitTestSize: 20.0,
              initCropRectType: InitCropRectType.imageRect,
              cropAspectRatio: CropAspectRatios.ratio4_3,
              editActionDetailsIsChanged: (EditActionDetails? details) {
                //print(details?.totalScale);
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.crop),
          onPressed: () {
            cropImage();
          }),
    );
  }

  Future<void> cropImage() async {
    if (_cropping) {
      return;
    }
    final Uint8List fileData = Uint8List.fromList(kIsWeb
        ? (await cropImageDataWithDartLibrary(state: editorKey.currentState!))!
        : (await cropImageDataWithNativeLibrary(
            state: editorKey.currentState!))!);
    final String? fileFath =
        await ImageSaver.save('extended_image_cropped_image.jpg', fileData);

    showToast('save image : $fileFath');
    _cropping = false;
  }
}
