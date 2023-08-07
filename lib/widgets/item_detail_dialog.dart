import 'package:flutter/material.dart';

import '../models/listitem.dart';
import '../services/dbhelper.dart';

class ItemDetailDialog extends StatelessWidget {
  const ItemDetailDialog({
    super.key,
    this.item,
    required this.checklistId,
  });
  final Item? item;
  final int checklistId;

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleCon = TextEditingController();
    final TextEditingController descCon = TextEditingController();
    bool isOwner = true;
    String dialogTitle = 'Add item';

    if (item != null) {
      titleCon.text = item!.title;
      descCon.text = item!.description;
      isOwner = DbHelper.isOwner(item!.ownerId);
      isOwner ? dialogTitle = 'Edit Item' : dialogTitle = item!.title;
    }

    return AlertDialog(
      title: Text(dialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isOwner)
            TextFormField(
              controller: titleCon,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                label: Text('Title'),
              ),
            ),
          if (isOwner)
            TextFormField(
              controller: descCon,
              onFieldSubmitted: (value) {
                _itemSaved(titleCon.text, descCon.text);
                Navigator.of(context).pop();
              },
              decoration: const InputDecoration(
                label: Text('Description'),
              ),
            ),
          if (!isOwner) Text(item!.description),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _itemSaved(titleCon.text, descCon.text);
            Navigator.of(context).pop();
          },
          child: const Text('save'),
        ),
      ],
    );
  }

  void _itemSaved(String title, String description) {
    DbHelper.addOrUpdateItem(
      checklistId,
      title,
      description,
      item?.id,
    );
  }
}
