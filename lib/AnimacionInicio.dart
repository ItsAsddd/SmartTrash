import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'animacionI2.dart'; // Asegúrate de que la ruta sea correcta

class AnimacionInicio extends StatefulWidget {
  @override
  _AnimacionInicioState createState() => _AnimacionInicioState();
}

class _AnimacionInicioState extends State<AnimacionInicio> with TickerProviderStateMixin {
  late AnimationController _dodecahedronController;
  late Animation<double> _rotationAnimation;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _buttonController;
  late Animation<double> _neonAnimation;
  late AnimationController _neonMovementController;
  late Animation<double> _neonMovementAnimation;
  List<String> _codeLines = [];
  List<Widget> _animatedTextWidgets = [];
  bool _showButton = false;

  @override
  void initState() {
    super.initState();

    _dodecahedronController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_dodecahedronController);

    _progressController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.linear,
    ));

    _buttonController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _neonAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    _neonMovementController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _neonMovementAnimation = Tween<double>(begin: 0, end: 10).animate(CurvedAnimation(
      parent: _neonMovementController,
      curve: Curves.easeInOut,
    ));

    _loadCodeText();
    Future.delayed(Duration(seconds: 1), () {
      _progressController.forward().whenComplete(() {
        setState(() {
          _showButton = true;
        });
        _buttonController.forward();
        _neonMovementController.repeat(reverse: true);
      });
    });
  }

  Future<void> _loadCodeText() async {
    String loadedText = await rootBundle.loadString('lib/assets/Cosas/codigo.txt');
    setState(() {
      _codeLines = loadedText.split('\n');
      _createAnimatedTextWidgets();
    });
  }

  void _createAnimatedTextWidgets() {
    _animatedTextWidgets.clear();
    for (int i = 0; i < _codeLines.length; i++) {
      _animatedTextWidgets.add(
        DelayedTextAnimation(
          text: _codeLines[i],
          delay: Duration(milliseconds: i * 1500), // 1.5 segundos entre líneas
        ),
      );
    }
  }

  @override
  void dispose() {
    _dodecahedronController.dispose();
    _progressController.dispose();
    _buttonController.dispose();
    _neonMovementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Otros elementos como el dodecaedro y el texto
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3, // Ajustar la posición vertical del dodecaedro
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: SizedBox(
                      width: 120, // Tamaño del dodecaedro
                      height: 120,
                      child: Image.asset(
                        'lib/assets/FX/sim.gif',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 20, // Ajusta la posición vertical del texto y la barra de progreso
            left: 70,
            right: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._animatedTextWidgets,
                SizedBox(height: 5),
                _buildProgressBar(),
              ],
            ),
          ),
          if (_showButton) ...[
            // Neon effect
            _buildNeonEffect(),

            // Button always on top
            Positioned(
              top: 500, // Altura deseada para el botón
              left: 0,
              right: 0,
              child: Center(
                child: _buildContinueButton(),
              ),
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(5),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progressAnimation.value,
            child: Container(
              color: Colors.green,
            ),
          ),
        );
      },
    );
  }

  Widget _buildContinueButton() {
    return AnimatedBuilder(
      animation: _buttonController,
      builder: (context, child) {
        return Opacity(
          opacity: _neonAnimation.value,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100), // Espacio desde la parte inferior
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  side: BorderSide(
                    color: Colors.green,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  _startGlitchTransition();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios, color: Colors.green),
                    SizedBox(width: 10),
                    Text(
                      'CONTINUE',
                      style: TextStyle(
                        color: Colors.green,
                        fontFamily: 'Courier',
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_ios, color: Colors.green),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }




  void _startGlitchTransition() {
    Navigator.of(context).push(_createGlitchPageRoute());
  }

  PageRouteBuilder _createGlitchPageRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => AnimacionI2(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: 0.0, end: 1.0);
        final opacityAnimation = animation.drive(tween.chain(CurveTween(curve: Curves.easeInOut)));
        final scaleAnimation = animation.drive(Tween(begin: 1.0, end: 2.0).chain(CurveTween(curve: Curves.easeInOut)));

        return FadeTransition(
          opacity: opacityAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildNeonEffect() {
    return AnimatedBuilder(
      animation: _neonMovementAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.green.withOpacity(0.4),
                Colors.green.withOpacity(0.1),
              ],
              stops: [0.0, 1.0],
              radius: _neonMovementAnimation.value,
            ),
            borderRadius: BorderRadius.circular(0),
          ),
        );
      },
    );
  }
}

class DelayedTextAnimation extends StatefulWidget {
  final String text;
  final Duration delay;

  DelayedTextAnimation({required this.text, required this.delay});

  @override
  _DelayedTextAnimationState createState() => _DelayedTextAnimationState();
}

class _DelayedTextAnimationState extends State<DelayedTextAnimation> {
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          widget.text,
          textStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'Courier',
            fontSize: 16,
          ),
          speed: const Duration(milliseconds: 100),
        ),
      ],
      isRepeatingAnimation: false,
    );
  }
}
