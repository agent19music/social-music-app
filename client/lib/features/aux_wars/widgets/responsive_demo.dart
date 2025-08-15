import 'package:flutter/material.dart';
import '../screens/aux_wars_screen.dart';

class ResponsiveDemo extends StatelessWidget {
  const ResponsiveDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 768) {
            // Desktop layout
            return Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.blue.withOpacity(0.1),
                          child: const Text(
                            'Mobile View (360x640)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              width: 360,
                              height: 640,
                              child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  size: const Size(360, 640),
                                ),
                                child: const AuxWarsScreen(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.green.withOpacity(0.1),
                          child: const Text(
                            'Desktop View (1200x800)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              size: const Size(1200, 800),
                            ),
                            child: const AuxWarsScreen(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Just show the regular responsive view
            return const AuxWarsScreen();
          }
        },
      ),
    );
  }
}
