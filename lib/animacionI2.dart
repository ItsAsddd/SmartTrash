import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:just_audio/just_audio.dart'; // Importa la librería
import 'dialogos1.dart';

class AnimacionI2 extends StatefulWidget {
  @override
  _AnimacionI2State createState() => _AnimacionI2State();
}

class _AnimacionI2State extends State<AnimacionI2> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _transitionDone = false;
  final AudioPlayer _ambientPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // Configura el sonido de ambiente en loop
    _initAudio();

    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeController.addListener(() {
      if (_fadeController.isCompleted && !_transitionDone) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => NewScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset.zero;
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end);
              var offsetAnimation = animation.drive(tween.chain(CurveTween(curve: curve)));
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
        setState(() {
          _transitionDone = true;
        });
      }
    });

    Timer(Duration(seconds: 1), () {
      _fadeController.forward();
    });
  }

  Future<void> _initAudio() async {
    try {
      await _ambientPlayer.setAsset('lib/assets/SFX/menu.wav');
      _ambientPlayer.setLoopMode(LoopMode.all); // Configura el audio en bucle
      _ambientPlayer.setVolume(1.0); // Configura el volumen
      _ambientPlayer.play();
      print("Ambient audio started playing");
    } catch (e) {
      print("Error setting audio asset: $e");
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo negro con animación
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Image.asset(
                    'lib/assets/FX/sim.gif',
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Clase para la nueva pantalla que mostrará el diálogo después de 5 segundos
class NewScreen extends StatefulWidget {
  @override
  _NewScreenState createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  bool _showDialog = false; // Controla si el diálogo se muestra o no

  @override
  void initState() {
    super.initState();

    // Espera 5 segundos antes de mostrar el diálogo
    Timer(Duration(seconds: 5), () {
      setState(() {
        _showDialog = true; // Muestra el diálogo después de 5 segundos
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo negro para el espacio
          Container(
            color: Colors.black,
          ),
          // Estrellas animadas
          Positioned.fill(
            child: StarLayer(),
          ),
          // Asteroides que aparecen cada 30 segundos
          Positioned.fill(
            child: AsteroidLayer(),
          ),
          // Estrellas que aparecen cada 10 segundos
          Positioned.fill(
            child: AnimatedStarLayer(),
          ),
          // Imagen nivel0 (aumentar tamaño aquí)
          Center(
            child: SizedBox(
              width: 300, // Tamaño ajustado
              height: 300, // Tamaño ajustado
              child: Image.asset(
                'lib/assets/Planetas/nivel0.gif',
                fit: BoxFit.contain, // Ajusta el contenido si es necesario
              ),
            ),
          ),
          // Mostrar el diálogo después de 5 segundos
          if (_showDialog)
            Positioned.fill(
              child: Dialogos1(), // Agrega el widget de diálogo aquí
            ),
        ],
      ),
    );
  }
}


class StarLayer extends StatelessWidget {
  final Random _random = Random();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Crear 35 estrellas con posiciones fijas
    final List<Widget> stars = List.generate(50, (index) {
      // Generar posiciones aleatorias dentro del tamaño de la pantalla
      final double x = _random.nextDouble() * size.width;
      final double y = _random.nextDouble() * size.height;

      return Positioned(
        left: x,
        top: y,
        child: Star(
          key: ValueKey(index),
          initialOpacity: _random.nextDouble(),
          duration: Duration(milliseconds: _random.nextInt(1000) + 500), // Duración entre 500ms y 1500ms
        ),
      );
    });

    return Stack(
      children: stars,
    );
  }
}

class Star extends StatefulWidget {
  final double initialOpacity;
  final Duration duration;

  const Star({Key? key, required this.initialOpacity, required this.duration}) : super(key: key);

  @override
  _StarState createState() => _StarState();
}

class _StarState extends State<Star> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: widget.initialOpacity, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: child,
        );
      },
      child: Image.asset(
        'lib/assets/Planetas/star.png',
        width: 15,
        height: 15,
      ),
    );
  }
}

class AsteroidLayer extends StatefulWidget {
  @override
  _AsteroidLayerState createState() => _AsteroidLayerState();
}

class _AsteroidLayerState extends State<AsteroidLayer> {
  final Random _random = Random();
  late Timer _timer;
  List<Offset> _positions = [];
  final List<bool> _visibility = [false, false, false];

  @override
  void initState() {
    super.initState();
    _scheduleAsteroids();
  }

  void _scheduleAsteroids() {
    _timer = Timer.periodic(Duration(seconds: 30), (Timer timer) {
      // Actualizar posiciones aleatorias para los 3 asteroides
      _positions = List.generate(3, (index) {
        return Offset(
          _random.nextDouble() * MediaQuery.of(context).size.width,
          _random.nextDouble() * MediaQuery.of(context).size.height,
        );
      });

      setState(() {
        // Mostrar los asteroides
        _visibility.setAll(0, [true, true, true]);
      });

      Timer(Duration(milliseconds: 200), () {
        setState(() {
          // Ocultar los asteroides
          _visibility.setAll(0, [false, false, false]);
        });
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(3, (index) {
        return Positioned(
          left: _positions.length > index ? _positions[index].dx : 0,
          top: _positions.length > index ? _positions[index].dy : 0,
          child: Visibility(
            visible: _visibility[index],
            child: Image.asset(
              'lib/assets/Planetas/asteroide.gif',
              width: 50,
              height: 50,
            ),
          ),
        );
      }),
    );
  }
}

class AnimatedStarLayer extends StatefulWidget {
  @override
  _AnimatedStarLayerState createState() => _AnimatedStarLayerState();
}

class _AnimatedStarLayerState extends State<AnimatedStarLayer> {
  final Random _random = Random();
  late Timer _timer;
  List<Offset> _positions = [];
  final List<bool> _visibility = [false, false, false];

  @override
  void initState() {
    super.initState();
    _scheduleStars();
  }

  void _scheduleStars() {
    _timer = Timer.periodic(Duration(seconds: 7), (Timer timer) {
      // Actualizar posiciones aleatorias para las estrellas
      _positions = List.generate(3, (index) {
        return Offset(
          _random.nextDouble() * MediaQuery.of(context).size.width,
          _random.nextDouble() * MediaQuery.of(context).size.height,
        );
      });

      setState(() {
        // Mostrar las estrellas
        _visibility.setAll(0, [true, true, true]);
      });

      Timer(Duration(milliseconds: 800), () {
        setState(() {
          // Ocultar las estrellas
          _visibility.setAll(0, [false, false, false]);
        });
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(1, (index) {
        return Positioned(
          left: _positions.length > index ? _positions[index].dx : 0,
          top: _positions.length > index ? _positions[index].dy : 0,
          child: Visibility(
            visible: _visibility[index],
            child: Image.asset(
              'lib/assets/Planetas/star.gif',
              width: 50,
              height: 50,
            ),
          ),
        );
      }),
    );
  }
}