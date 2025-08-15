import 'package:flutter/material.dart';

class AssetTestWidget extends StatelessWidget {
  const AssetTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asset Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Test direct asset loading
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
              ),
              child: Image.asset(
                'assets/images/mbdtfaa.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) {
                  print('Direct asset error: $error');
                  return Container(
                    color: Colors.red,
                    child: const Center(
                      child: Text(
                        'Failed to load mbdtfaa.jpg',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Test albumart directory
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
              ),
              child: Image.asset(
                'assets/images/albumart/mbdtfaa.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) {
                  print('Albumart directory error: $error');
                  return Container(
                    color: Colors.orange,
                    child: const Center(
                      child: Text(
                        'Failed to load from albumart/',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Test another album
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.purple),
              ),
              child: Image.asset(
                'assets/images/albumart/astroworld.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) {
                  print('Astroworld error: $error');
                  return Container(
                    color: Colors.purple,
                    child: const Center(
                      child: Text(
                        'Failed to load astroworld.jpg',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
