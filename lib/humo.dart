import 'dart:math';
import 'package:flutter/material.dart';

class Humo extends StatefulWidget {
  const Humo({super.key});

  @override
  _HumoState createState() => _HumoState();
}

class _HumoState extends State<Humo> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned.fill(
      child: Stack(
        children: List.generate(100, (index) {
          final image = index % 3 == 0
              ? 'lib/assets/Residuos/humo.png'
              : index % 3 == 1
              ? 'lib/assets/Residuos/humo2.png'
              : 'lib/assets/Residuos/humo3.png';

          final opacity = 0.01 + Random().nextDouble() * 0.006;

          final random = Random();
          final imageSize = 500 + random.nextDouble() * 100;
          final offsetX = random.nextDouble() * size.width;
          final offsetY = random.nextDouble() * size.height;

          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final animationValue = _animationController.value;
              final xOffset = (offsetX + animationValue * size.width) % size.width;
              final yOffset = (offsetY + animationValue * size.height) % size.height;

              return Positioned(
                left: xOffset - imageSize / 2,
                top: yOffset - imageSize / 2,
                child: Opacity(
                  opacity: opacity,
                  child: Image.asset(
                    image,
                    width: imageSize,
                    height: imageSize,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
