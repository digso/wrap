import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

extension WrapInherit on Widget {
  /// 将指定数据([data])登记在组件树(widget tree)中,
  /// 而后便可以通过`context.find<Type>()`在所有子组件的[BuildContext]中获取。
  ///
  /// 1. 此方法是对[Inherit]组件的封装。
  /// 2. 可通过设置[refresh]方法来决定什么情况下相关联的组件应当刷新。
  /// 3. 如果您的数据初始化后就不需要更改，请用[inheritFinal]来优化性能。
  Widget inherit<T>(T data, {bool Function(T newData, T oldData)? refresh}) =>
      Inherit<T>(data: data, refresh: refresh, child: this);

  /// Similar to [inherit], but this one is only for the condition that
  /// the [data] will never change after initialize,
  /// especially when the inherited ones are APIs to call.
  /// This method will call the [Inherit.wontChange] constructor
  /// to prevent unnecessary compares to improve the performance.
  ///
  Widget inheritFinal<T>(T data) => Inherit.wontChange(data: data, child: this);

  /// Wrap [InheritHandler] around this widget with given [data],
  /// [onUpdate] action register and the [renderer].
  ///
  /// 1. You can find the inherited [data] using [FindInherit.find].
  /// 2. You can update the inherited [data] using [FindInherit.update].
  /// 3. See the default constructor of [InheritHandler] for more details.
  ///
  Widget handle<T>(
    T data, {
    void Function(T data)? onUpdate,
    Widget Function(BuildContext context, T data, Widget child)? renderer,
  }) =>
      InheritHandler(
        data: data,
        onUpdate: onUpdate,
        renderer: renderer,
        child: this,
      );
}

extension FindInherit on BuildContext {
  /// Find data from widget tree with given type.
  /// Those data are stored inside into the widget tree
  /// using the [WrapInherit.inherit] extended on [Widget].
  ///
  /// As there might not be any [Inherit]ed data with given type,
  /// the return value might be null.
  /// You can consider using [findAndCheck], [findAndDefault], or [findAndTrust]
  /// for a conciser coding style, rather than processing the nullable result
  /// of this method.
  ///
  T? find<T>() => dependOnInheritedWidgetOfExactType<Inherit<T>>()?.data;

  /// [find] data from widget tree with given type.
  /// Those data are stored inside into the widget tree
  /// using the [WrapInherit.inherit] extended on [Widget].
  /// And if not found, then use the [defaultValue].
  ///
  T findAndDefault<T>(T defaultValue) => find<T>() ?? defaultValue;

  /// [find] inherited data from widget tree with given type.
  /// Those data are stored inside into the widget tree
  /// using the [WrapInherit.inherit] extended on [Widget].
  ///
  /// You must ensure the data will be found.
  /// There's only an `assert` to check whether it will find the data
  /// in debug mode and there's no check in release mode.
  /// If you cannot make sure there will be such data,
  /// please consider using [find] or [findAndCheck] as alternative.
  ///
  T findAndTrust<T>() {
    final data = find<T>();
    assert(data != null, 'cannot find $T in context');
    return data!;
  }

  /// [find] data from widget tree with given type.
  /// Those data are stored inside into the widget tree
  /// using the [WrapInherit.inherit] extended on [Widget].
  /// And if not found, then throw an exception.
  ///
  T findAndCheck<T>() {
    final data = find<T>();
    if (data == null) throw Exception('cannot find $T in context');
    return data;
  }

  void update<T>(T data) => find<void Function(T data)>()?.call(data);

  void checkAndUpdate<T>(T data) {
    final updater = find<void Function(T data)>();
    if (updater == null) throw Exception('cannot find $T updater in context');
    updater(data);
  }
}

/// 处理组件树继承的通用组件，详见其默认构造函数(constructor)。
class Inherit<T> extends InheritedWidget {
  /// 用于组件树继承的通用组件,
  /// 即将数据登记于此，而后在子组件的[BuildContext]就可以通过
  /// `context.find<Type>()` 来获取这个被登记的数据。
  ///
  /// 1. 如果您的数据初始化后就不需要更改,
  ///    请用[Inherit.wontChange]这个构造函数来优化性能。
  /// 2. 不建议直接使用此类构造函数,
  ///    更推荐用于链式编程的`const Example().inherit(xxx)`。
  /// 3. `context.find<Type>()`是根据类别来查找的,
  ///    在使用的时候同一层次不要使用相同的类别,
  ///    否则可能会导致数据覆盖。若实在要使用可考虑类型封装。
  const Inherit({
    super.key,
    this.refresh,
    required this.data,
    required super.child,
  });

  Inherit.wontChange({
    super.key,
    required this.data,
    required super.child,
  }) : refresh = ((newData, oldData) => false);

  /// 决定引用了[data]的组件是否应当被应当随其变化而刷新的函数。
  /// 如果未指定此方法，则将使用旧数据与当前数据进行比较，若变化则刷新。
  /// 如果您的数据一直都不会变化，就让它直接返回false，
  /// 否则比较变量还会耗费一定的开销。
  final bool Function(T newData, T oldData)? refresh;
  final T data;

  @override
  bool updateShouldNotify(covariant Inherit<T> oldWidget) => refresh != null
      ? refresh!(this.data, oldWidget.data)
      : this.data != oldWidget.data;
}

/// A stateful widget to handle inherit data and data change in widget tree.
/// - See its default constructor for more details.
class InheritHandler<T> extends StatefulWidget {
  /// A stateful widget to handle inherit data and data change in widget tree.
  ///
  /// 1. You can use [FindInherit.find] to get the inherit [data] just like
  ///    the [Inherit] widget. This widget uses an [Inherit] widget
  ///    to provide the [data] in the widget tree.
  /// 2. You can then use [FindInherit.update] to update the [data].
  /// 3. You can also register [onUpdate] actions which will be triggered
  ///    once the [data] is changed, not matter from its descendants
  ///    or ancestors (outside the widget) in the widget tree.
  /// 4. You can customize a [renderer] to modify its child as the [data].
  ///
  const InheritHandler({
    super.key,
    required this.data,
    this.onUpdate,
    this.renderer,
    required this.child,
  });

  final T data;
  final void Function(T data)? onUpdate;
  final Widget Function(BuildContext context, T data, Widget child)? renderer;
  final Widget child;

  @override
  State<InheritHandler<T>> createState() => _InheritHandlerState();
}

class _InheritHandlerState<T> extends State<InheritHandler<T>> {
  late T _data = widget.data;

  void update(T data) {
    if (_data != data) {
      setState(() => _data = data);
      widget.onUpdate?.call(data);
    }
  }

  @override
  void didUpdateWidget(covariant InheritHandler<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    update(widget.data);
  }

  @override
  Widget build(BuildContext context) {
    final handler = widget.child.inherit(_data).inheritFinal(update);
    return widget.renderer?.call(context, _data, handler) ?? handler;
  }
}
