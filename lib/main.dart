import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:classcheck_in/app.dart';
import 'package:classcheck_in/services/attendance_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_US', null);

  final store = AttendanceStore();
  await store.initialize();

  runApp(ClassCheckInApp(store: store));
}
