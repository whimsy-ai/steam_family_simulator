import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

class MyTable extends StatefulWidget {
  final int rowCount;
  final int columnCount;
  final Widget Function(BuildContext context, int row, int column) cellBuilder;
  final Widget Function(BuildContext context, int column)? headerCellBuilder;
  final Widget Function(BuildContext context, int row)? firstColumnBuilder;
  final bool separator;
  final Widget Function(BuildContext context, double width, double height)?
      leftTopWidgetBuilder;
  final double? headerHeight;
  final double? firstColumnWidth;
  final double rowHeight;
  final double columnWidth;
  final Color? headerColor, firstColumnColor;
  final LinkedScrollControllerGroup verticalScrolls;

  const MyTable({
    super.key,
    required this.cellBuilder,
    required this.rowCount,
    required this.columnCount,
    required this.verticalScrolls,
    this.firstColumnWidth,
    this.separator = true,
    this.headerCellBuilder,
    this.firstColumnBuilder,
    this.leftTopWidgetBuilder,
    this.columnWidth = 300,
    this.rowHeight = 30,
    this.headerHeight,
    this.headerColor,
    this.firstColumnColor,
  });

  @override
  State<MyTable> createState() => _MyTableState();
}

class _MyTableState extends State<MyTable> {
  late ScrollController _horizontal, _vertical1, _vertical2;

  late LinkedScrollControllerGroup _horizontals;
  late final _verticals = widget.verticalScrolls;

  late final List<ScrollController> _controllers =
      List.generate(widget.rowCount + 1, (i) => _horizontals.addAndGet());

  @override
  void initState() {
    super.initState();
    // print('initState  rowCount:${widget.rowCount}');
    _horizontals = LinkedScrollControllerGroup();
    _horizontal = _horizontals.addAndGet();
    _vertical1 = _verticals.addAndGet();
    _vertical2 = _verticals.addAndGet();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(
        'didUpdateWidget row:${widget.rowCount}, column:${widget.columnCount}');
    if (widget.rowCount > _controllers.length) {
      _controllers.addAll(List.generate(widget.rowCount - _controllers.length,
          (i) => _horizontals.addAndGet()));
    }
  }

  @override
  void dispose() {
    for (var element in _controllers) {
      element.dispose();
    }
    super.dispose();
  }

  Widget _header() {
    final height = widget.headerHeight ?? widget.rowHeight;
    // print('header height $height');
    Widget child = SizedBox(
      height: height,
      child: Row(
        children: [
          SizedBox(
            width: widget.firstColumnWidth ?? widget.columnWidth,
            child: widget.leftTopWidgetBuilder?.call(
              context,
              widget.columnWidth,
              height,
            ),
          ),
          Expanded(
            child: ListView.separated(
                controller: _horizontal,
                scrollDirection: Axis.horizontal,
                itemBuilder: (c, i) {
                  return SizedBox(
                    width: widget.columnWidth,
                    height: widget.headerHeight ?? widget.rowHeight,
                    child: widget.headerCellBuilder!(context, i),
                  );
                },
                separatorBuilder: (_, i) => VerticalDivider(width: 1),
                itemCount: widget.columnCount),
          ),
        ],
      ),
    );
    if (widget.headerColor != null) {
      child = ColoredBox(color: widget.headerColor!, child: child);
    }
    return child;
  }

  Widget _firstColumn(BuildContext context) {
    Widget child = SizedBox(
      width: widget.firstColumnWidth ?? widget.columnWidth,
      child: ListView.separated(
        controller: _vertical1,
        itemCount: widget.rowCount,
        separatorBuilder: (c, i) => Divider(height: 1),
        itemBuilder: (c, row) => SizedBox(
          height: widget.rowHeight,
          child: widget.firstColumnBuilder!(c, row),
        ),
      ),
    );
    if (widget.firstColumnColor != null) {
      child = ColoredBox(color: widget.firstColumnColor!, child: child);
    }
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.headerCellBuilder != null) _header(),
        Expanded(
          child: LayoutBuilder(builder: (context, constrains) {
            // print('$constrains');
            return Row(
              children: [
                if (widget.firstColumnBuilder != null) _firstColumn(context),
                Expanded(
                  child: ListView.separated(
                    controller: _vertical2,
                    itemCount: widget.rowCount,
                    itemBuilder: _rowBuilder,
                    separatorBuilder: (c, i) => widget.separator
                        ? Divider(height: 1)
                        : SizedBox.shrink(),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _rowBuilder(context, int row) {
    return SizedBox(
      height: widget.rowHeight,
      child: ListView.separated(
        separatorBuilder: (context, i) =>
            widget.separator ? VerticalDivider(width: 1) : SizedBox.shrink(),
        scrollDirection: Axis.horizontal,
        controller: _controllers[row],
        itemCount: widget.columnCount,
        itemBuilder: (context, column) => SizedBox(
          width: widget.columnWidth,
          child: widget.cellBuilder(context, row, column),
        ),
      ),
    );
  }
}
