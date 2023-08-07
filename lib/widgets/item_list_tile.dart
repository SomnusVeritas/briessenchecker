import 'package:flutter/material.dart';

typedef BoolCallback = void Function(bool isSelected);

class ItemListTile extends StatefulWidget {
  const ItemListTile({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
    required this.itemSelectionChanged,
    required this.selectionMode,
    required this.isChecked,
    required this.onCheckedChanged,
  });
  final String title;
  final String description;
  final bool selectionMode;
  final bool isChecked;
  final VoidCallback onTap;
  final BoolCallback onCheckedChanged;
  final BoolCallback itemSelectionChanged;

  @override
  State<ItemListTile> createState() => _ItemListTileState();
}

class _ItemListTileState extends State<ItemListTile> {
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.isChecked;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.title),
      subtitle: Text(widget.description),
      onTap: _onTap,
      onLongPress: _onLongPress,
      trailing: Checkbox(
        value: isChecked,
        onChanged: (value) {
          setState(() => isChecked = value!);
          widget.onCheckedChanged(value!);
        },
      ),
    );
  }

  void _onLongPress() {
    setState(() => isChecked = true);
    widget.itemSelectionChanged(isChecked);
  }

  void _onTap() {
    if (isChecked || widget.selectionMode) {
      setState(() => isChecked = !isChecked);
      widget.itemSelectionChanged(isChecked);
    } else {
      widget.onTap();
    }
  }
}
