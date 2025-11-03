import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // App name
          const Text(
            'My Fiş App',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // App icon in circle
          const CircleAvatar(
            radius: 100,
            backgroundImage: AssetImage('assets/icon/AppImage.jpg'),
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(height: 12),
          const Text(
            'Küçük işletmeniz için fişlerinizi zahmetsizce taratın, kaydedin ve gönderin. '
            'Uygulamamız, sorunsuz, hızlı fişlerinizi dijital ortama almanıza yardımcı olmak için tasarlanmıştır.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),

          // Feature list
          _buildFeatureTile(Icons.description,
              'Fişlerinizi taratın, kaydedin, doğrulayın ve kendiniz yönetin.'),
          _buildFeatureTile(Icons.payments,
              'Ödemelerinizi takip edin ve muhasebeciniz ile paylaşın.'),
          _buildFeatureTile(
              Icons.bar_chart, 'Anlamlı finansal takip raporları oluşturun.'),
          _buildFeatureTile(Icons.security,
              'Resimlerinizi ve dosyalarınızı güvenli bir şekilde saklayın.'),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
