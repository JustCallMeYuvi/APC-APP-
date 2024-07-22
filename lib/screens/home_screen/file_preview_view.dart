import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
class FullScreenImageView extends StatelessWidget {
  final Uint8List imageBytes;

  const FullScreenImageView({Key? key, required this.imageBytes})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.memory(imageBytes),
      ),
    );
  }
}
class FilePreviewView extends StatefulWidget {
  final Uint8List fileBytes;
  final String filename;

  const FilePreviewView(
      {Key? key, required this.fileBytes, required this.filename})
      : super(key: key);

  @override
  _FilePreviewViewState createState() => _FilePreviewViewState();
}

class _FilePreviewViewState extends State<FilePreviewView> {
  bool _isDownloading = false;

  Future<void> _downloadAndOpenFile() async {
    try {
      // Request storage permission
      if (await Permission.storage.request().isGranted) {
        setState(() {
          _isDownloading = true;
        });

        // Get the directory to save the file
        Directory? directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory != null) {
          // Create the file with the provided fileName
          File file = File('${directory.path}/${widget.filename}');

          // Write the bytes to the file
          await file.writeAsBytes(widget.fileBytes);

          // Open the file using open_file package
          final result = await OpenFile.open(file.path);
          if (result.type != ResultType.done) {
            throw Exception('Failed to open file');
          }
        } else {
          throw Exception('Could not get the storage directory');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission denied to save file'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download and open file: $e'),
        ),
      );
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.filename),
      ),
      body: Center(
        child: _isDownloading
            ? CircularProgressIndicator()
            : GestureDetector(
                onTap: _downloadAndOpenFile,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.insert_drive_file, size: 100, color: Colors.grey),
                    const SizedBox(height: 20),
                    Text('Tap to download and open ${widget.filename}'),
                  ],
                ),
              ),
      ),
    );
  }
}
