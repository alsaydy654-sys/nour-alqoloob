/// قارئ من قرّاء القرآن مع مصدر التلاوة (بث MP3 من mp3quran.net).
class Reciter {
  final String id;
  final String arabicName;
  final String latinName;
  final String baseUrl;
  const Reciter({
    required this.id,
    required this.arabicName,
    required this.latinName,
    required this.baseUrl,
  });

  /// رابط تلاوة سورة برقمها (1..114).
  String urlForSurah(int number) =>
      '$baseUrl${number.toString().padLeft(3, '0')}.mp3';
}

const List<Reciter> kReciters = [
  Reciter(
    id: 'afs',
    arabicName: 'مشاري راشد العفاسي',
    latinName: 'Mishary Rashid Alafasy',
    baseUrl: 'https://server8.mp3quran.net/afs/',
  ),
  Reciter(
    id: 'basit',
    arabicName: 'عبد الباسط عبد الصمد',
    latinName: 'Abdul Basit Abdul Samad',
    baseUrl: 'https://server7.mp3quran.net/basit/',
  ),
  Reciter(
    id: 'maher',
    arabicName: 'ماهر المعيقلي',
    latinName: 'Maher Al-Muaiqly',
    baseUrl: 'https://server12.mp3quran.net/maher/',
  ),
  Reciter(
    id: 's_gmd',
    arabicName: 'سعد الغامدي',
    latinName: 'Saad Al-Ghamdi',
    baseUrl: 'https://server7.mp3quran.net/s_gmd/',
  ),
  Reciter(
    id: 'yasser',
    arabicName: 'ياسر الدوسري',
    latinName: 'Yasser Al-Dosari',
    baseUrl: 'https://server11.mp3quran.net/yasser/',
  ),
  Reciter(
    id: 'sds',
    arabicName: 'عبد الرحمن السديس',
    latinName: 'Abdul Rahman Al-Sudais',
    baseUrl: 'https://server11.mp3quran.net/sds/',
  ),
];

Reciter reciterById(String id) =>
    kReciters.firstWhere((r) => r.id == id, orElse: () => kReciters.first);
