import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_application_google_map/search/search_bloc.dart';

import '../map/map_bloc.dart';
import '../map/map_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => MapBloc()),
          BlocProvider(create: (context) => SearchBloc()),
        ],
        child: MaterialApp(
          title: 'Test Application',
          theme: ThemeData(
            colorSchemeSeed: Colors.green[700],
            useMaterial3: true,
          ),
          home: const MapPage(),
        ));
  }
}
