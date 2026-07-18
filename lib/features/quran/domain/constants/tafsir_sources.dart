/// Known tafsir edition IDs from api.alquran.cloud with Arabic labels.
abstract final class TafsirSources {
  static const offlineSourceId = 'offline_arabic_text';

  static const preferredOrder = <String>[
    'ar.waseet',
    'ar.muyassar',
    'ar.jalalayn',
    'ar.qurtubi',
    'ar.miqbas',
    'ar.baghawi',
  ];

  static const labels = <String, String>{
    'ar.waseet': 'التفسير الوسيط (مصر)',
    'ar.muyassar': 'التفسير الميسر',
    'ar.jalalayn': 'تفسير الجلالين',
    'ar.qurtubi': 'تفسير القرطبي',
    'ar.miqbas': 'تنوير المقباس',
    'ar.baghawi': 'تفسير البغوي',
    offlineSourceId: 'النص العربي (احتياطي بدون إنترنت)',
  };

  static String labelFor(String sourceId) =>
      labels[sourceId] ?? labels.entries
          .firstWhere(
            (e) => sourceId.contains(e.key),
            orElse: () => MapEntry(sourceId, sourceId),
          )
          .value;
}
