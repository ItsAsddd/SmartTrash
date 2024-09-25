import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class Dialogos1 extends StatefulWidget {
  @override
  _Dialogos1State createState() => _Dialogos1State();
}

class _Dialogos1State extends State<Dialogos1> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  late AnimationController _floatController;
  late Animation<Offset> _floatAnimation;

  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;

  late AnimationController _fadeController; // Controlador de animación de desvanecimiento
  late Animation<double> _fadeAnimation;

  int _currentDialogueIndex = 0;
  bool _canChangeDialogue = true; // Variable para manejar el cooldown

  final List<String> _dialogues = [
    "No temas...",
    "Soy el Dios Universo.",
    "He creado esta simulación.",
    "Para mostrarte las consecuencias...",
    "De que tires basura por todos lados.",
    "Ustedes, los humanos de tu Universo",
    "¡Tomen conciencia de sus actos!",
    "Aún tienen tiempo, sin embargo...",
    "Como puedes ver, aquí la Tierra es...",
    "INHABITABLE...",
    "Es por eso que te he elegido a ti",
    "Para que... con tu ayuda",
    "Podamos devolver la vida a la Tierra.",
    "El futuro del planeta depende de ti.",
    "Comienza ahora.",
    "¡El destino del mundo está en tus manos!"
  ];

  late String _currentDialogue;

  final AudioPlayer _player = AudioPlayer(); // Instancia de AudioPlayer

  @override
  void initState() {
    super.initState();

    // Controlador para deslizar el diálogo
    _slideController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1), // Comienza desde la parte inferior de la pantalla
      end: Offset(0, 0),   // Termina en su posición final
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward(); // Inicia la animación cuando se carga

    // Controlador para la animación de flotación
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, -0.005), // Ajuste menor para un efecto de flotación más sutil
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    // Controlador para la animación del botón NEXT1
    _buttonController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    // Controlador para la animación de desvanecimiento
    _fadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Inicia la animación del botón NEXT1 después de 2 segundos
    Future.delayed(Duration(seconds: 2), () {
      _buttonController.forward();
    });

    _currentDialogue = _dialogues[_currentDialogueIndex];
  }

  void _nextDialogue() async {
    if (_canChangeDialogue) {
      setState(() {
        _canChangeDialogue = false; // Desactiva el cambio de diálogo
      });

      // Cambia el índice y el diálogo
      if (_currentDialogueIndex < _dialogues.length - 1) {
        setState(() {
          _currentDialogueIndex++;
          _currentDialogue = _dialogues[_currentDialogueIndex];
        });

        // Reproduce un sonido aleatorio
        int randomIndex = Random().nextInt(3) + 1; // Selecciona un número aleatorio entre 1 y 3
        String soundPath = 'lib/assets/SFX/Space/Sonidos/fx/alien$randomIndex.mp3';

        try {
          await _player.setAsset(soundPath);
          _player.play();
        } catch (e) {
          print('Error al reproducir el sonido: $e');
        }

        // Reactiva el cambio de diálogo después del cooldown
        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            _canChangeDialogue = true;
          });
        });

      } else {
        // Último diálogo, sonido específico y deshabilita GestureDetectors
        String soundPath = 'lib/assets/SFX/Space/Sonidos/fx/scream.wav';

        try {
          await _player.setAsset(soundPath);
          _player.play();
        } catch (e) {
          print('Error al reproducir el sonido: $e');
        }

        // Desactiva los GestureDetectors
        setState(() {
          _canChangeDialogue = false; // Desactiva permanentemente el cambio de diálogo
        });

        // Inicia la animación de desvanecimiento
        _fadeController.forward().whenComplete(() {
          // Navegar a main.dart después de la animación de desvanecimiento
          Navigator.pushReplacementNamed(context, '/main');
        });
      }
    }
  }


  @override
  void dispose() {
    _slideController.dispose();
    _floatController.dispose();
    _buttonController.dispose();
    _fadeController.dispose(); // Dispose del controlador de desvanecimiento
    _player.dispose(); // Dispose del AudioPlayer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Stack(
            clipBehavior: Clip.none, // Permite que los elementos se superpongan
            children: [
              // Caja de diálogo con tamaño fijo y más grande
              GestureDetector(
                onTap: _nextDialogue,
                child: Container(
                  width: MediaQuery.of(context).size.width - 40, // Tamaño fijo para la caja de diálogo
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  margin: EdgeInsets.zero, // No dejar espacio en la parte inferior
                  decoration: BoxDecoration(
                    color: Colors.purple[100], // Color de fondo morado claro
                    border: Border.all(
                      color: Colors.purple[900]!, // Color de borde morado oscuro
                      width: 4,
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _nextDialogue,
                        child: SizedBox(height: 30), // Espacio en blanco en la parte superior
                      ),
                      Text(
                        _currentDialogue,
                        style: TextStyle(
                          fontFamily: 'Pixel', // Usa la fuente "Pixel"
                          fontWeight: FontWeight.bold, // Fuente en negrita
                          fontSize: 18,
                          color: Colors.purple[900], // Color del texto morado oscuro
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis, // Añadido para cortar el texto largo
                        maxLines: 2, // Limita el texto a dos líneas
                      ),
                    ],
                  ),
                ),
              ),

              // Botón next1.png fuera de la caja de texto, ajustado para que no se sobreponga
              Positioned(
                top: 15, // Ajusta esta posición para que esté visualmente separado
                right: 15,
                child: GestureDetector(
                  onTap: _nextDialogue, // Acción que se ejecuta al tocar el botón
                  child: FadeTransition(
                    opacity: _buttonAnimation,
                    child: Image.asset(
                      'lib/assets/Personaje/Assets/Extra/next1.png',
                      width: 30, // Tamaño del botón
                      height: 30,
                    ),
                  ),
                ),
              ),

              // Asset dios1.png que sobresale de la caja de diálogo
              Positioned(
                top: -50, // Ajusta esta posición para sobresalir más o menos
                left: (MediaQuery.of(context).size.width - 120) / 2 - 20, // Calcula la posición centrada
                child: SlideTransition(
                  position: _floatAnimation, // Usa la misma animación de deslizamiento
                  child: Image.asset(
                    'lib/assets/Personaje/Assets/Extra/dios1.png',
                    width: 120, // Ajusta el tamaño del asset si es necesario
                    height: 120,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}