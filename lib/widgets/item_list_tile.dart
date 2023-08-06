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
  });
  final String title;
  final String description;
  final bool selectionMode;
  final VoidCallback onTap;
  final BoolCallback itemSelectionChanged;

  @override
  State<ItemListTile> createState() => _ItemListTileState();
}

class _ItemListTileState extends State<ItemListTile> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.title),
      subtitle: Text(widget.description),
      onTap: _onTap,
      onLongPress: _onLongPress,
      selected: isSelected,
    );
  }

  void _onLongPress() {
    setState(() => isSelected = true);
    widget.itemSelectionChanged(isSelected);
  }

  void _onTap() {
    if (isSelected || widget.selectionMode) {
      setState(() => isSelected = !isSelected);
      widget.itemSelectionChanged(isSelected);
    } else {
      widget.onTap();
    }
  }
}
