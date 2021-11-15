import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({Key? key, required this.value, required this.data})
      : super(key: key);
  // input async value
  final AsyncValue<T> value;
  // output builder function
  final Widget Function(T) data;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (e, t) => Center(
        child: Text(
          e.toString(),
          style: Theme.of(context)
              .textTheme
              .headline6!
              .copyWith(color: Colors.red),
        ),
      ),
    );
  }
}

class AsyncValueSliverWidget<T> extends StatelessWidget {
  const AsyncValueSliverWidget(
      {Key? key, required this.value, required this.data})
      : super(key: key);
  // input async value
  final AsyncValue<T> value;
  // output builder function
  final Widget Function(T) data;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => const SliverToBoxAdapter(
          child: Center(child: CupertinoActivityIndicator())),
      error: (e, a) => SliverToBoxAdapter(
        child: Center(
          child: Text(
            e.toString(),
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
