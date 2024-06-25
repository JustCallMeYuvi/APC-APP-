import 'package:web_socket_channel/web_socket_channel.dart';

class NotificationService {
  final WebSocketChannel channel;

  NotificationService(String url) : channel = WebSocketChannel.connect(Uri.parse(url));

  Stream<String> get stream => channel.stream.map((event) => event.toString());
}
