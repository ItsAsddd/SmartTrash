import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importa shared_preferences
import 'AnimacionInicio.dart'; // Importa el archivo de la animación de inicio
import 'dart:async';
import 'dart:math'; // Importa para usar Random
import 'humo.dart'; // Importa el archivo de humo
import 'personaje.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura la inicialización de Flutter

  // Revisa si es la primera vez que se abre la aplicación
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  if (isFirstTime) {
    // Marca que ya no es la primera vez
    await prefs.setBool('isFirstTime', false);
  }

  runApp(MyApp(isFirstTime: isFirstTime));
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;

  const MyApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Trash',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isFirstTime
          ? AnimacionInicio() // Si es la primera vez, muestra la animación de inicio
          : const MyHomePage(title: 'Flutter Smoke Background'), // De lo contrario, muestra la pantalla principal
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _cursorScaleController;
  double _opacity = 1.0; // Inicialmente la capa negra está visible
  bool _cursorVisible = false;
  bool _cursorVisibleDelayed = false;
  int _tapCount = 0;
  Timer? _cursorVisibilityTimer;
  List<_DustEffect> _dustEffects = []; // Lista para almacenar los efectos de polvo

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _cursorScaleController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Temporizador para la capa negra
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _opacity = 0.0; // Cambia la opacidad para revelar la pantalla
      });
      _animationController.forward();
    });

    // Temporizador para el cursor
    Timer(const Duration(seconds: 8), () {
      if (_tapCount < 10) { // Solo muestra el cursor si no se han realizado 10 toques
        setState(() {
          _cursorVisible = true; // Muestra el cursor después de 8 segundos
          _cursorVisibleDelayed = true;
          _cursorScaleController.repeat(reverse: true); // Repite la animación de escala
        });

        // Configura el temporizador para la visibilidad del cursor
        _cursorVisibilityTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
          if (_cursorVisibleDelayed && _tapCount < 30) {
            setState(() {
              _cursorVisible = true; // Muestra el cursor si no se ha tocado la pantalla
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cursorScaleController.dispose();
    _cursorVisibilityTimer?.cancel();
    super.dispose();
  }

  void _incrementTapCount() {
    setState(() {
      _tapCount++;
      _cursorVisible = false; // Oculta el cursor al hacer un toque
      _cursorVisibleDelayed = false; // Detiene la visibilidad automática del cursor

      // Reinicia el temporizador de visibilidad del cursor
      _cursorVisibilityTimer?.cancel();
      _cursorVisibilityTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_tapCount < 10) {
          setState(() {
            _cursorVisible = true; // Muestra el cursor si no se ha tocado la pantalla
            _cursorVisibleDelayed = true;
          });
        }
      });

      if (_tapCount % 3 == 0) {
        _playDustEffect(); // Reproduce el GIF de polvo cada 3 toques
      }
    });
  }

  void _playDustEffect() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Configura el rango para la posición aleatoria cerca del personaje
    final double characterCenterX = screenWidth / 2;
    final double characterCenterY = screenHeight / 2;
    final double radius = 80.0; // Radio en píxeles alrededor del personaje

    // Genera una posición aleatoria en un círculo
    final double size = 100 + (20 * (_tapCount % 3)).toDouble();
    final double angle = Random().nextDouble() * 2 * pi; // Ángulo aleatorio
    final double distance = Random().nextDouble() * radius; // Distancia aleatoria dentro del radio
    final double offsetX = characterCenterX - size / 2 + distance * cos(angle);
    final double offsetY = characterCenterY - size / 2 + distance * sin(angle);

    setState(() {
      _dustEffects.add(_DustEffect(
        left: offsetX,
        top: offsetY,
        size: size,
      ));
    });

    // Oculta el efecto de polvo después de que se haya reproducido
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        if (_dustEffects.isNotEmpty) {
          _dustEffects.removeAt(0);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'lib/assets/Residuos/fondoinicialb.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Efectos de humo
          const Humo(), // Usa el widget de humo
          // Efectos de polvo
          for (_DustEffect dustEffect in _dustEffects)
            Positioned(
              left: dustEffect.left,
              top: dustEffect.top,
              child: Image.asset(
                'lib/assets/FX/Efectos/polvo.gif', // Asegúrate de usar la ruta correcta
                width: dustEffect.size,
                height: dustEffect.size,
              ),
            ),
          // Personaje en el centro de la pantalla
          Personaje(
            tapCount: _tapCount,
            onTapUpdate: _incrementTapCount,
          ),
          // Capa negra que se desvanece sobre todos los elementos
          AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(seconds: 3),
            child: Container(
              color: Colors.black,
              child: const SizedBox.expand(),
            ),
          ),
          // Botón invisible para detectar toques
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _incrementTapCount(); // Incrementar la cuenta de toques
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Cursor que aparece y desaparece
          _cursorVisible && _tapCount < 30 // Solo muestra el cursor si no se han realizado 10 toques
              ? Positioned(
            top: MediaQuery.of(context).size.height / 2 - -25,
            left: MediaQuery.of(context).size.width / 2 - -25,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(
                  parent: _cursorScaleController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: Image.asset(
                'lib/assets/Iconos/cursor.png',
                width: 50,
                height: 50,
              ),
            ),
          )
              : Container(), // Ocultar el cursor si no se deben mostrar
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AnimacionInicio()),
          );
        },
        child: const Icon(Icons.replay),
      ),
    );
  }
}

class _DustEffect {
  final double left;
  final double top;
  final double size;

  _DustEffect({required this.left, required this.top, required this.size});
}
