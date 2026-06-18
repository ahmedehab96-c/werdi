import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:werdi/app.dart';
import 'package:werdi/core/services/bootstrap_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BootstrapService.init();
  runApp(const ProviderScope(child: WerdiApp()));
}
