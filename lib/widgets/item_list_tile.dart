import 'package:briessenchecker/services/dbhelper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/profile_provider.dart';

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
    this.ownerId = '',
  });
  final String title;
  final String description;
  final bool selectionMode;
  final bool isChecked;
  final VoidCallback onTap;
  final BoolCallback onCheckedChanged;
  final BoolCallback itemSelectionChanged;
  final String ownerId;

  @override
  State<ItemListTile> createState() => _ItemListTileState();
}

class _ItemListTileState extends State<ItemListTile> {
  late bool isChecked;
  bool isSelected = false;
  late ProfileProvider profileProvider;

  @override
  void initState() {
    super.initState();
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    isChecked = widget.isChecked;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.description),
          Text(
            profileProvider.getProfileById(widget.ownerId)?.username ?? '',
            style: const TextStyle(color: Colors.grey),
          )
        ],
      ),
      onTap: _onTap,
      onLongPress: _onLongPress,
      selected: isSelected,
      trailing: Visibility(
        visible: !widget.selectionMode,
        child: Checkbox(
          value: isChecked,
          onChanged: (value) {
            setState(() => isChecked = value!);
            widget.onCheckedChanged(value!);
          },
        ),
      ),
    );
  }

  void _onLongPress() {
    setState(() => isSelected = !isSelected);
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
