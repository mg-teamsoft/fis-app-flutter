import 'package:fis_app_flutter/app/import/app.dart';
import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/model/notification_model.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data mapped via NotificationModel
    final notifications = [
      NotificationModel(
        id: '1',
        title: 'Yeni Fiş Yüklendi',
        subtitle: null,
        content:
            'Fiş detayları sisteme eklendi ve incelemenizi bekliyor. Fiş numarası: #481920. '
            'Ofis kırtasiye harcamaları dahilindedir. Lütfen fiş bilgilerini kontrol edip '
            'onaylayınız. Onaylanmayan fişler 7 gün içinde otomatik olarak silinecektir. '
            'Herhangi bir sorun olması durumunda destek ekibimizle iletişime geçebilirsiniz.',
        time: '10 dk önce',
        isUnread: true,
      ),
      NotificationModel(
        id: '2',
        title: 'Aylık Rapor Hazır',
        subtitle: 'Aylık finansal özetiniz incelemeye hazır.',
        content:
            'Geçen aya ait tüm makbuzlarınızı ve harcamalarınızı kapsayan aylık özet raporunuz '
            'hazırlandı. Uygulama içerisinden indirebilirsiniz. Raporda toplam 47 adet fiş '
            'bulunmaktadır. Toplam harcama tutarı 12.450,75 TL olarak hesaplanmıştır. '
            'Kategorilere göre dağılım: Ofis Malzemeleri %35, Yemek %25, Ulaşım %20, '
            'Diğer %20. Detaylı analiz için raporun PDF versiyonunu indirmenizi öneririz. '
            'Rapor 30 gün boyunca erişilebilir olacaktır.',
        time: '2 saat önce',
        isUnread: false,
      ),
      NotificationModel(
        id: '3',
        title: 'Sistem Güncellemesi',
        subtitle: null,
        content:
            'Sunucularımızda performans iyileştirmesi yapılacağı için saat 02:00 ile 04:00 '
            'arasında kısa süreli kesintiler yaşanabilir. Bu süre zarfında fiş yükleme, '
            'rapor oluşturma ve Excel dışa aktarma işlemleri geçici olarak kullanılamayacaktır. '
            'Güncelleme tamamlandıktan sonra tüm hizmetler otomatik olarak yeniden başlatılacaktır. '
            'Lütfen önemli işlemlerinizi bakım saatinden önce tamamlayınız.',
        time: 'Dün',
        isUnread: false,
      ),
      NotificationModel(
        id: '4',
        title: 'Yeni Özellik: Toplu Fiş Yükleme',
        subtitle: 'Artık birden fazla fişi aynı anda yükleyebilirsiniz.',
        content:
            'Uzun süredir talep edilen toplu fiş yükleme özelliği artık kullanıma sunulmuştur. '
            'Galeri sayfasından birden fazla fotoğraf seçerek tek seferde en fazla 10 adet fiş '
            'yükleyebilirsiniz. Sistem her bir fişi ayrı ayrı işleyecek ve sonuçları size '
            'bildirecektir. İşlem sırasında ilerleme durumunu takip edebilirsiniz. Bu özellik '
            'sayesinde ay sonu fiş girişlerinizi çok daha hızlı tamamlayabileceksiniz. '
            'Herhangi bir hata ile karşılaşmanız durumunda lütfen geri bildirimde bulununuz.',
        time: '3 gün önce',
        isUnread: true,
      ),
    ];

    return Column(
      children: [
        Text(
          'Bildirimler',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) =>
                Divider(color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final isUnread = notif.isUnread;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6, right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isUnread ? Colors.blue : Colors.transparent,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ThemeTypography.h4(
                            context,
                            notif.title,
                            color: context.colorScheme.onSurface,
                            weight: FontWeight.w800,
                          ),
                          const SizedBox(height: 4),
                          if (notif.subtitle != null)
                            ThemeTypography.titleMedium(
                              context,
                              notif.subtitle ?? '',
                              color: Colors.grey.shade600,
                            )
                          else
                            const SizedBox.shrink(),
                          const SizedBox(height: 6),
                          ThemeTypography.bodyMedium(
                            context,
                            notif.content,
                            color: Colors.grey.shade800,
                          ),
                          const SizedBox(height: 8),
                          ThemeTypography.bodyMedium(
                            context,
                            notif.time,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
