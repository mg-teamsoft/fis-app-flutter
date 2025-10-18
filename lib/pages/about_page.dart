import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hakkında')),
      body: Center(child: Text('Fiş App bir muhasebe takip uygulamasıdır.')),
    );
  }
}
