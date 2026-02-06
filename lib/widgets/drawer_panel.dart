import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DrawerPanel extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final Widget child;

  const DrawerPanel({
    super.key,
    required this.title,
    required this.onClose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox.expand(
        child: Stack(
          children: [
            GestureDetector(
              onTap: onClose,
              child: Container(color: Colors.black54),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: appBarBackground,
                child: Container(
                  width: 350,
                  height: double.infinity,
                  constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.9),
                  decoration: BoxDecoration(
                    color: appBarBackground,
                    border: Border(left: BorderSide(color: borderColor)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: onClose,
                              icon: const Icon(Icons.close, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Colors.white12),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: child,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
