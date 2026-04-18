import 'package:flutter/material.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ui_parts.dart';

class SpeedBlitzScreen extends StatelessWidget {
  const SpeedBlitzScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Speed Blitz',
      subtitle: '1 / 10',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: GlowCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const LinearProgressIndicator(value: .85, minHeight: 8),
            const SizedBox(height: 8),
            const Text('11s', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const GlowCard(child: Text('Under RA 10175, which type of cybercrime involves intentionally accessing a computer system without right?', textAlign: TextAlign.center)),
            const SizedBox(height: 12),
            ...['Data Interference', 'Illegal Interception', 'Illegal Access', 'Computer Fraud'].map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(onPressed: () {}, child: Align(alignment: Alignment.centerLeft, child: Text(e))),
                )),
          ]),
        ),
      ),
    );
  }
}
