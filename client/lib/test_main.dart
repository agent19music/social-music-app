import 'package:flutter/material.dart';
import 'features/aux_wars/screens/aux_wars_screen.dart';
import 'asset_test.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatefulWidget {
  const TestApp({super.key});

  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  bool showAssetTest = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aux Wars Test',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            showAssetTest ? const AssetTestWidget() : const AuxWarsScreen(),
            Positioned(
              top: 50,
              right: 20,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  setState(() {
                    showAssetTest = !showAssetTest;
                  });
                },
                child: Icon(showAssetTest ? Icons.music_note : Icons.image),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
