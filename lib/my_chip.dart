import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyChip extends StatelessWidget {
  late final RxBool selected = RxBool(false);

  final String label;
  final bool Function()? onSelect;
  final void Function(bool)? onChanged;

  MyChip({
    super.key,
    required this.label,
    this.onChanged,
    this.onSelect,
    bool selected = false,
  }) {
    this.selected
      ..value = selected
      ..listen((p0) {
        onChanged?.call(p0);
      });
  }

  @override
  Widget build(BuildContext context) => Obx(
        () => ChoiceChip(
          selected: selected.value,
          label: Text(label),
          onSelected: (v) {
            selected.value = onSelect?.call() ?? v;
          },
        ),
      );
}
