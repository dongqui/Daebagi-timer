import 'package:flutter/material.dart';

import 'package:catodo/features/presentation/views/focus_form/form.dart';

class FocusFormOverlay extends StatelessWidget {
  const FocusFormOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black,
          width: double.infinity,
          height: double.infinity,
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SizedBox(
            height: 330,
            child: FocusForm(),
          ),
        ),
      ],
    );
  }
}
