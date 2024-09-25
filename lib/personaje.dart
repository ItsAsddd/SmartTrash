import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class Personaje extends StatefulWidget {
  final int tapCount;
  final VoidCallback onTapUpdate;

  const Personaje({
    super.key,
    required this.tapCount,
    required this.onTapUpdate,
  });

  @override
  _PersonajeState createState() => _PersonajeState();
}

class _PersonajeState extends State<Personaje> with TickerProviderStateMixin {
  late AnimationController _cursorController;
  late Animation<double> _cursorScaleAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _particlesController;
  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnimation;
  late AnimationController _dustController; // Controlador para el efecto de polvo
  List<Widget> _particles = [];
  bool _gestureDetected = false;
  bool _cursorVisible = false;
  String _currentCharacterAsset = 'lib/assets/Personaje/Assets/Stand/Tsleep1.png';
  late double _shakeAmplitude; // Amplitud de shake aleatoria
  late double _shakeDirection; // Dirección de shake aleatoria

  @override
  void initState() {
    super.initState();

    _cursorController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _cursorScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _cursorController,
      curve: Curves.easeInOut,
    ));

    _fadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _particlesController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 800), // Duración del shake en 0.8 segundos
      vsync: this,
    );

    _shakeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero, // Se actualizará dinámicamente en cada cuadro
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    _dustController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Mostrar el cursor después de 10 segundos
    Timer(const Duration(seconds: 10), () {
      if (!_gestureDetected) {
        setState(() {
          _cursorVisible = true;
        });
        _cursorController.repeat(reverse: true);
      }
    });

    // Ocultar el cursor si se detecta un toque
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_gestureDetected && _cursorVisible) {
        setState(() {
          _cursorVisible = true;
        });
        _cursorController.repeat(reverse: true);
      } else {
        _cursorController.stop();
      }
    });
  }

  @override
  void dispose() {
    _cursorController.dispose();
    _fadeController.dispose();
    _particlesController.dispose();
    _shakeController.dispose();
    _dustController.dispose(); // Dispose del controlador de polvo
    super.dispose();
  }

  void _generateParticles() {
    final random = Random();
    final newParticles = List.generate(5, (index) {
      final size = random.nextDouble() * 10 + 5;
      final left = MediaQuery.of(context).size.width / 2 + random.nextDouble() * 50 - 25;
      final top = MediaQuery.of(context).size.height / 2 + random.nextDouble() * 50 - 25;
      final color = random.nextBool() ? Colors.brown : Colors.black;

      return Positioned(
        left: left,
        top: top,
        child: FadeTransition(
          opacity: _particlesController,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    });

    setState(() {
      _particles.addAll(newParticles);
    });

    _particlesController.forward(from: 0.0).then((_) {
      setState(() {
        _particles.clear();
      });
    });
  }

  void _startShakeAnimation() {
    final random = Random();
    _shakeAmplitude = random.nextDouble() * 20.0; // Amplitud de shake aleatoria
    _shakeDirection = random.nextDouble() * 2 * pi; // Dirección de shake aleatoria en radianes

    _shakeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(
        _shakeAmplitude * cos(_shakeDirection),
        _shakeAmplitude * sin(_shakeDirection),
      ),
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  void _startDustEffect() {
    print('Starting dust effect');
    final random = Random();
    final newDustParticles = List.generate(20, (index) {
      final angle = 2 * pi * random.nextDouble();
      final distance = random.nextDouble() * 50 + 20;
      final size = random.nextDouble() * 20 + 10;
      final left = MediaQuery.of(context).size.width / 2 + distance * cos(angle) - size / 2;
      final top = MediaQuery.of(context).size.height / 2 + distance * sin(angle) - size / 2;
      final imageAsset = ['humo.png', 'humo2.png', 'humo3.png'][random.nextInt(3)];

      print('Particle: left=$left, top=$top, size=$size');

      return Positioned(
        left: left,
        top: top,
        child: AnimatedBuilder(
          animation: _dustController,
          builder: (context, child) {
            final animationValue = _dustController.value;
            return Opacity(
              opacity: 1 - animationValue,
              child: Transform.scale(
                scale: 1 + 2 * animationValue,
                child: Image.asset(
                  'lib/assets/Residuos/$imageAsset',
                  width: size,
                  height: size,
                ),
              ),
            );
          },
        ),
      );
    });

    setState(() {
      _particles.addAll(newDustParticles);
    });

    _dustController.forward().then((_) {
      setState(() {
        _particles.clear();
      });
    });
  }


  @override
  void didUpdateWidget(covariant Personaje oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.tapCount != oldWidget.tapCount) {
      setState(() {
        _gestureDetected = true;
        _startShakeAnimation(); // Inicia la animación de shake
        _generateParticles();

        if (widget.tapCount % 3 == 0) {
          _startDustEffect(); // Inicia el efecto de polvo
        }

        if (widget.tapCount >= 30) {
          _cursorController.stop();
          _currentCharacterAsset = 'lib/assets/Personaje/Assets/Stand/AnimaT1.gif';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height / 2 - 50,
      left: MediaQuery.of(context).size.width / 2 - 50,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              widget.onTapUpdate();
            },
            child: AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                return Transform.translate(
                  offset: _shakeAnimation.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(_currentCharacterAsset),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_cursorVisible)
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 25,
              left: MediaQuery.of(context).size.width / 2 - 25,
              child: ScaleTransition(
                scale: _cursorScaleAnimation,
                child: Image.asset(
                  'lib/assets/Iconos/cursor.png',
                  width: 50,
                  height: 50,
                ),
              ),
            ),
          // Añadir partículas de polvo
          ..._particles,
        ],
      ),
    );
  }
}
