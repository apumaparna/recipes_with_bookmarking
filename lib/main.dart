import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'data/memory_repository.dart';

import 'ui/main_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  _setupLogging();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// initializes the logging package and allows Chopper to log requests and responses.
// Set the level to Level.ALL so that you see every log statement.
void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the ChangeNotifierProvider that has the type MemoryRepository.
    return ChangeNotifierProvider<MemoryRepository>(
      // Set lazy to false, which creates the repository right away instead of
      // waiting until you need it. This is useful when the repository has to
      // do some background work to start up.
      lazy: false,
      // Create your repository.
      create: (_) => MemoryRepository(),
      // Return MaterialApp as the child widget.
      child: MaterialApp(
        title: 'Recipes',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.white,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MainScreen(),
      ),
    );
  }
}
