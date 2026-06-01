import 'package:flutter/material.dart';
// import 'package:rive/rive.dart';


class RiveLabScreen extends StatefulWidget {
  const RiveLabScreen({super.key});

  @override
  State<RiveLabScreen> createState() => _RiveLabScreenState();
}

class _RiveLabScreenState extends State<RiveLabScreen> {
  dynamic controller;

  dynamic idle;
  dynamic walk;
  dynamic jump;
  dynamic attack;

  dynamic lookX;
  dynamic lookY;

  String currentState = "Idle";

  void onRiveInit(Artboardartboard) {
    final smController;
    // final smController =
    // StateMachineController.fromArtboard(
    //   artboard,
    //   'State Machine 1',
    // );

    // if (smController == null) return;
    //
    // //artboard.addController(smController);
    //
    // controller = smController;

    idle = controller.findInput<bool>('Idle');
    walk = controller.findInput<bool>('Walk');

    jump = controller.findInput<bool>('Jump');
    attack = controller.findInput<bool>('Attack');

    lookX = controller.findInput<double>('LookX');
    lookY = controller.findInput<double>('LookY');
  }

  void activateIdle() {
    if (idle != null) {
      idle.value = true;
    }

    if (walk != null) {
      walk.value = false;
    }

    setState(() {
      currentState = "Idle";
    });
  }

  void activateWalk() {
    if (idle != null) {
      idle.value = false;
    }

    if (walk != null) {
      walk.value = true;
    }

    setState(() {
      currentState = "Walk";
    });
  }

  void activateJump() {
    jump?.fire();

    setState(() {
      currentState = "Jump";
    });
  }

  void activateAttack() {
    attack?.fire();

    setState(() {
      currentState = "Attack";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B14),
      body: Center(
        child: MouseRegion(
          onHover: (event) {
            lookX?.value = event.localPosition.dx;
            lookY?.value = event.localPosition.dy;
          },
          child: Image.asset(
            'assets/rive/robot.riv',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}