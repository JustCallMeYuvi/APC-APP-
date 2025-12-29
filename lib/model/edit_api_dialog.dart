import 'package:flutter/material.dart';
import 'package:animated_movies_app/model/endpoint_model.dart';
import 'package:animated_movies_app/screens/ui_local_and_global_api_screens/endpoint_service.dart';

class EditApiDialog extends StatefulWidget {
  final EndpointModel model;

  const EditApiDialog({Key? key, required this.model}) : super(key: key);

  @override
  State<EditApiDialog> createState() => _EditApiDialogState();
}

class _EditApiDialogState extends State<EditApiDialog> {
  late TextEditingController projectCtrl;
  late TextEditingController publicCtrl;
  late TextEditingController localCtrl;
  late bool isActive;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    projectCtrl = TextEditingController(text: widget.model.projectName);
    publicCtrl = TextEditingController(text: widget.model.publicApiUrl);
    localCtrl = TextEditingController(text: widget.model.localApiUrl);
    isActive = widget.model.isActive;
  }

  Future<void> _update() async {
    setState(() => isLoading = true);

    final updated = widget.model.copyWith(
      projectName: projectCtrl.text.trim(),
      publicApiUrl: publicCtrl.text.trim(),
      localApiUrl: localCtrl.text.trim(),
      isActive: isActive,
    );

    final success = await EndpointService.updateEndpoint(updated);

    setState(() => isLoading = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Update failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit API"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: projectCtrl,
              decoration: const InputDecoration(labelText: "Project Name"),
            ),
            TextField(
              controller: publicCtrl,
              decoration: const InputDecoration(labelText: "Public API"),
            ),
            TextField(
              controller: localCtrl,
              decoration: const InputDecoration(labelText: "Local API"),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text("Active"),
              value: isActive,
              onChanged: (v) => setState(() => isActive = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _update,
          child: isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Update"),
        ),
      ],
    );
  }
}
