import 'package:animated_movies_app/model/edit_api_dialog.dart';
import 'package:animated_movies_app/model/endpoint_model.dart';
import 'package:animated_movies_app/screens/ui_local_and_global_api_screens/endpoint_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RealtimeApiScreen extends StatefulWidget {
  const RealtimeApiScreen({Key? key}) : super(key: key);

  @override
  State<RealtimeApiScreen> createState() => RealtimeApiScreenState();
}

class RealtimeApiScreenState extends State<RealtimeApiScreen> {
  late Future<List<EndpointModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = EndpointService.fetchEndpoints();
  }

  void refresh() {
    setState(() {
      _future = EndpointService.fetchEndpoints();
    });
  }

  Future<void> openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

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
    return FutureBuilder<List<EndpointModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final realtimeList =
            snapshot.data!.where((e) => e.server == "RealTime").toList();

        if (realtimeList.isEmpty) {
          return const Center(child: Text("No Realtime APIs"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: realtimeList.length,
          itemBuilder: (context, index) {
            final item = realtimeList[index];

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
                    const SnackBar(content: Text("API deleted successfully")),
                  );
                  refresh();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Delete failed")),
                  );
                  refresh();
                }
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.wifi, color: Colors.green),
                  title: Text(
                    item.projectName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text("Public: ${item.publicApiUrl}"),
                      // Text("Local: ${item.localApiUrl}"),

                      GestureDetector(
                        onTap: () => openUrl(item.publicApiUrl),
                        child: Text(
                          "Public: ${item.publicApiUrl}",
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () => openUrl(item.localApiUrl),
                        child: Text(
                          "Local: ${item.localApiUrl}",
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
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
