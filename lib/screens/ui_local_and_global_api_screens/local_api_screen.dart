import 'package:animated_movies_app/model/edit_api_dialog.dart';
import 'package:animated_movies_app/model/endpoint_model.dart';
import 'package:animated_movies_app/screens/ui_local_and_global_api_screens/endpoint_service.dart';
import 'package:flutter/material.dart';

class LocalApiScreen extends StatefulWidget {
  const LocalApiScreen({Key? key}) : super(key: key);

  @override
  State<LocalApiScreen> createState() => LocalApiScreenState();
}

class LocalApiScreenState extends State<LocalApiScreen> {
  Future<List<EndpointModel>>? _future;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _future = EndpointService.fetchEndpoints();
  }

  void refresh() {
    setState(() {
      _loadData();
    });
  }

  /// 🔔 Confirmation dialog
  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete API"),
        content: const Text("Are you sure you want to delete this API?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🛡 Safety guard
    if (_future == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<EndpointModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final testList =
            snapshot.data!.where((e) => e.server == "Test").toList();

        if (testList.isEmpty) {
          return const Center(child: Text("No Test APIs"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: testList.length,
          itemBuilder: (context, index) {
            final item = testList[index];

            return Dismissible(
              key: ValueKey(item.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) => _confirmDelete(context),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) async {
                final success = await EndpointService.deleteEndpoint(item.id);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("API deleted")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Delete failed")),
                  );
                }
                refresh();
              },
              child: Card(
                color: Colors.grey.shade100,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.storage, color: Colors.blue),
                  title: Text(
                    item.projectName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Public: ${item.publicApiUrl}"),
                      Text("Local: ${item.localApiUrl}"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      final updated = await showDialog<bool>(
                        context: context,
                        builder: (_) => EditApiDialog(model: item),
                      );

                      if (updated == true) {
                        refresh(); // ✅ REFRESH LIST
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("API updated successfully")),
                        );
                      }
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
