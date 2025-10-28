import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          const Center(
            child: Column(
              children: [
                Text(
                  "Toplam Tutar",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 4),
                Text(
                  "₺1.700,00",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Totals Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _TotalTile(title: "Aylık Fiş Sayısı", value: "8"),
              _TotalTile(title: "Toplam KDV", value: "₺374,60"),
            ],
          ),

          const SizedBox(height: 20),

          // Action Buttons
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/receipt');
                  },
                  icon: const Icon(Icons.upload),
                  label: const Text("Fiş Yükle"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/excelFiles');
                  },
                  icon: const Icon(Icons.table_chart),
                  label: const Text("Excel Görüntüle"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Recent Activity
          const Text(
            "Son Fişler",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // Static dummy items for now
          const _InvoiceItem(
              title: "Migros", date: "7 Ekim", amount: "₺425,00"),
          const _InvoiceItem(title: "A101", date: "6 Ekim", amount: "₺298,40"),
          const _InvoiceItem(title: "Şok", date: "5 Ekim", amount: "₺211,00"),
        ],
      ),
    );
  }
}

class _TotalTile extends StatelessWidget {
  final String title;
  final String value;

  const _TotalTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

class _InvoiceItem extends StatelessWidget {
  final String title;
  final String date;
  final String amount;

  const _InvoiceItem({
    required this.title,
    required this.date,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.receipt_long),
      title: Text(title),
      subtitle: Text(date),
      trailing: Text(
        amount,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
