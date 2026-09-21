import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

void main() async {
  var calls = await FlutterCallkitIncoming.activeCalls();
  print(calls);
}
