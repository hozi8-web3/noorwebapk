import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_theme.dart';

class Names99Screen extends StatelessWidget {
  const Names99Screen({super.key});

  static const List<Map<String, String>> _names = [
    {'number': '1', 'arabic': 'اللَّهُ', 'transliteration': 'Allah', 'meaning': 'The One God'},
    {'number': '2', 'arabic': 'الرَّحْمَنُ', 'transliteration': 'Ar-Rahman', 'meaning': 'The Most Gracious'},
    {'number': '3', 'arabic': 'الرَّحِيمُ', 'transliteration': 'Ar-Raheem', 'meaning': 'The Most Merciful'},
    {'number': '4', 'arabic': 'الْمَلِكُ', 'transliteration': 'Al-Malik', 'meaning': 'The King'},
    {'number': '5', 'arabic': 'الْقُدُّوسُ', 'transliteration': 'Al-Quddus', 'meaning': 'The Most Holy'},
    {'number': '6', 'arabic': 'السَّلَامُ', 'transliteration': 'As-Salam', 'meaning': 'The Source of Peace'},
    {'number': '7', 'arabic': 'الْمُؤْمِنُ', 'transliteration': "Al-Mu'min", 'meaning': 'The Guardian of Faith'},
    {'number': '8', 'arabic': 'الْمُهَيْمِنُ', 'transliteration': 'Al-Muhaymin', 'meaning': 'The Protector'},
    {'number': '9', 'arabic': 'الْعَزِيزُ', 'transliteration': 'Al-Azeez', 'meaning': 'The Almighty'},
    {'number': '10', 'arabic': 'الْجَبَّارُ', 'transliteration': 'Al-Jabbar', 'meaning': 'The Compeller'},
    {'number': '11', 'arabic': 'الْمُتَكَبِّرُ', 'transliteration': 'Al-Mutakabbir', 'meaning': 'The Greatest'},
    {'number': '12', 'arabic': 'الْخَالِقُ', 'transliteration': 'Al-Khaliq', 'meaning': 'The Creator'},
    {'number': '13', 'arabic': 'الْبَارِئُ', 'transliteration': "Al-Bari'", 'meaning': 'The Originator'},
    {'number': '14', 'arabic': 'الْمُصَوِّرُ', 'transliteration': 'Al-Musawwir', 'meaning': 'The Fashioner'},
    {'number': '15', 'arabic': 'الْغَفَّارُ', 'transliteration': 'Al-Ghaffar', 'meaning': 'The Forgiving'},
    {'number': '16', 'arabic': 'الْقَهَّارُ', 'transliteration': 'Al-Qahhar', 'meaning': 'The Subduer'},
    {'number': '17', 'arabic': 'الْوَهَّابُ', 'transliteration': 'Al-Wahhab', 'meaning': 'The Bestower'},
    {'number': '18', 'arabic': 'الرَّزَّاقُ', 'transliteration': 'Ar-Razzaq', 'meaning': 'The Provider'},
    {'number': '19', 'arabic': 'الْفَتَّاحُ', 'transliteration': 'Al-Fattah', 'meaning': 'The Opener'},
    {'number': '20', 'arabic': 'الْعَلِيمُ', 'transliteration': "Al-'Aleem", 'meaning': 'The All-Knowing'},
    {'number': '21', 'arabic': 'الْقَابِضُ', 'transliteration': 'Al-Qabid', 'meaning': 'The Restrainer'},
    {'number': '22', 'arabic': 'الْبَاسِطُ', 'transliteration': 'Al-Basit', 'meaning': 'The Extender'},
    {'number': '23', 'arabic': 'الْخَافِضُ', 'transliteration': 'Al-Khafid', 'meaning': 'The Abaser'},
    {'number': '24', 'arabic': 'الرَّافِعُ', 'transliteration': "Ar-Rafi'", 'meaning': 'The Exalter'},
    {'number': '25', 'arabic': 'الْمُعِزُّ', 'transliteration': "Al-Mu'izz", 'meaning': 'The Honourer'},
    {'number': '26', 'arabic': 'الْمُذِلُّ', 'transliteration': 'Al-Mudhill', 'meaning': 'The Humiliator'},
    {'number': '27', 'arabic': 'السَّمِيعُ', 'transliteration': 'As-Samee', 'meaning': 'The All-Hearing'},
    {'number': '28', 'arabic': 'الْبَصِيرُ', 'transliteration': 'Al-Baseer', 'meaning': 'The All-Seeing'},
    {'number': '29', 'arabic': 'الْحَكَمُ', 'transliteration': 'Al-Hakam', 'meaning': 'The Judge'},
    {'number': '30', 'arabic': 'الْعَدْلُ', 'transliteration': "Al-'Adl", 'meaning': 'The Just'},
    {'number': '31', 'arabic': 'اللَّطِيفُ', 'transliteration': 'Al-Lateef', 'meaning': 'The Subtle One'},
    {'number': '32', 'arabic': 'الْخَبِيرُ', 'transliteration': 'Al-Khabeer', 'meaning': 'The All-Aware'},
    {'number': '33', 'arabic': 'الْحَلِيمُ', 'transliteration': 'Al-Haleem', 'meaning': 'The Forbearing'},
    {'number': '34', 'arabic': 'الْعَظِيمُ', 'transliteration': "Al-'Azeem", 'meaning': 'The Most Great'},
    {'number': '35', 'arabic': 'الْغَفُورُ', 'transliteration': 'Al-Ghafoor', 'meaning': 'The All-Forgiving'},
    {'number': '36', 'arabic': 'الشَّكُورُ', 'transliteration': 'Ash-Shakoor', 'meaning': 'The Appreciative'},
    {'number': '37', 'arabic': 'الْعَلِيُّ', 'transliteration': "Al-'Ali", 'meaning': 'The Most High'},
    {'number': '38', 'arabic': 'الْكَبِيرُ', 'transliteration': 'Al-Kabeer', 'meaning': 'The Most Great'},
    {'number': '39', 'arabic': 'الْحَفِيظُ', 'transliteration': 'Al-Hafeez', 'meaning': 'The Preserver'},
    {'number': '40', 'arabic': 'الْمُقِيتُ', 'transliteration': 'Al-Muqeet', 'meaning': 'The Sustainer'},
    {'number': '41', 'arabic': 'الْحَسِيبُ', 'transliteration': 'Al-Haseeb', 'meaning': 'The Reckoner'},
    {'number': '42', 'arabic': 'الْجَلِيلُ', 'transliteration': 'Al-Jaleel', 'meaning': 'The Majestic'},
    {'number': '43', 'arabic': 'الْكَرِيمُ', 'transliteration': 'Al-Kareem', 'meaning': 'The Generous'},
    {'number': '44', 'arabic': 'الرَّقِيبُ', 'transliteration': 'Ar-Raqeeb', 'meaning': 'The Watchful'},
    {'number': '45', 'arabic': 'الْمُجِيبُ', 'transliteration': 'Al-Mujeeb', 'meaning': 'The Responsive'},
    {'number': '46', 'arabic': 'الْوَاسِعُ', 'transliteration': "Al-Wasi'", 'meaning': 'The All-Encompassing'},
    {'number': '47', 'arabic': 'الْحَكِيمُ', 'transliteration': 'Al-Hakeem', 'meaning': 'The Wise'},
    {'number': '48', 'arabic': 'الْوَدُودُ', 'transliteration': 'Al-Wadood', 'meaning': 'The Loving'},
    {'number': '49', 'arabic': 'الْمَجِيدُ', 'transliteration': 'Al-Majeed', 'meaning': 'The Most Glorious'},
    {'number': '50', 'arabic': 'الْبَاعِثُ', 'transliteration': "Al-Ba'ith", 'meaning': 'The Resurrector'},
    {'number': '51', 'arabic': 'الشَّهِيدُ', 'transliteration': 'Ash-Shaheed', 'meaning': 'The Witness'},
    {'number': '52', 'arabic': 'الْحَقُّ', 'transliteration': 'Al-Haqq', 'meaning': 'The Truth'},
    {'number': '53', 'arabic': 'الْوَكِيلُ', 'transliteration': 'Al-Wakeel', 'meaning': 'The Trustee'},
    {'number': '54', 'arabic': 'الْقَوِيُّ', 'transliteration': 'Al-Qawiyy', 'meaning': 'The Most Strong'},
    {'number': '55', 'arabic': 'الْمَتِينُ', 'transliteration': 'Al-Mateen', 'meaning': 'The Firm'},
    {'number': '56', 'arabic': 'الْوَلِيُّ', 'transliteration': 'Al-Waliyy', 'meaning': 'The Protecting Friend'},
    {'number': '57', 'arabic': 'الْحَمِيدُ', 'transliteration': 'Al-Hameed', 'meaning': 'The Praiseworthy'},
    {'number': '58', 'arabic': 'الْمُحْصِيُ', 'transliteration': 'Al-Muhsi', 'meaning': 'The Counter'},
    {'number': '59', 'arabic': 'الْمُبْدِئُ', 'transliteration': "Al-Mubdi'", 'meaning': 'The Originator'},
    {'number': '60', 'arabic': 'الْمُعِيدُ', 'transliteration': "Al-Mu'eed", 'meaning': 'The Restorer'},
    {'number': '61', 'arabic': 'الْمُحْيِي', 'transliteration': 'Al-Muhyi', 'meaning': 'The Giver of Life'},
    {'number': '62', 'arabic': 'الْمُمِيتُ', 'transliteration': 'Al-Mumeet', 'meaning': 'The Taker of Life'},
    {'number': '63', 'arabic': 'الْحَيُّ', 'transliteration': 'Al-Hayy', 'meaning': 'The Ever-Living'},
    {'number': '64', 'arabic': 'الْقَيُّومُ', 'transliteration': 'Al-Qayyoom', 'meaning': 'The Self-Subsisting'},
    {'number': '65', 'arabic': 'الْوَاجِدُ', 'transliteration': 'Al-Wajid', 'meaning': 'The Finder'},
    {'number': '66', 'arabic': 'الْمَاجِدُ', 'transliteration': 'Al-Majid', 'meaning': 'The Glorious'},
    {'number': '67', 'arabic': 'الْوَاحِدُ', 'transliteration': 'Al-Wahid', 'meaning': 'The One'},
    {'number': '68', 'arabic': 'الصَّمَدُ', 'transliteration': 'As-Samad', 'meaning': 'The Eternal'},
    {'number': '69', 'arabic': 'الْقَادِرُ', 'transliteration': 'Al-Qadir', 'meaning': 'The Capable'},
    {'number': '70', 'arabic': 'الْمُقْتَدِرُ', 'transliteration': 'Al-Muqtadir', 'meaning': 'The Powerful'},
    {'number': '71', 'arabic': 'الْمُقَدِّمُ', 'transliteration': 'Al-Muqaddim', 'meaning': 'The Foremost'},
    {'number': '72', 'arabic': 'الْمُؤَخِّرُ', 'transliteration': "Al-Mu'akhkhir", 'meaning': 'The Deferrer'},
    {'number': '73', 'arabic': 'الأَوَّلُ', 'transliteration': 'Al-Awwal', 'meaning': 'The First'},
    {'number': '74', 'arabic': 'الآخِرُ', 'transliteration': 'Al-Akhir', 'meaning': 'The Last'},
    {'number': '75', 'arabic': 'الظَّاهِرُ', 'transliteration': 'Az-Zahir', 'meaning': 'The Manifest'},
    {'number': '76', 'arabic': 'الْبَاطِنُ', 'transliteration': 'Al-Batin', 'meaning': 'The Hidden'},
    {'number': '77', 'arabic': 'الْوَالِي', 'transliteration': 'Al-Waali', 'meaning': 'The Governor'},
    {'number': '78', 'arabic': 'الْمُتَعَالِي', 'transliteration': "Al-Muta'ali", 'meaning': 'The Most Exalted'},
    {'number': '79', 'arabic': 'الْبَرُّ', 'transliteration': 'Al-Barr', 'meaning': 'The Good'},
    {'number': '80', 'arabic': 'التَّوَّابُ', 'transliteration': 'At-Tawwab', 'meaning': 'The Acceptor of Repentance'},
    {'number': '81', 'arabic': 'الْمُنْتَقِمُ', 'transliteration': 'Al-Muntaqim', 'meaning': 'The Avenger'},
    {'number': '82', 'arabic': 'الْعَفُوُّ', 'transliteration': "Al-'Afuww", 'meaning': 'The Pardoner'},
    {'number': '83', 'arabic': 'الرَّؤُوفُ', 'transliteration': "Ar-Ra'oof", 'meaning': 'The Clement'},
    {'number': '84', 'arabic': 'مَالِكُ الْمُلْكُ', 'transliteration': 'Malik-ul-Mulk', 'meaning': 'Owner of Sovereignty'},
    {'number': '85', 'arabic': 'ذُوالْجَلَالِ وَالإِكْرَامِ', 'transliteration': 'Dhul-Jalal wal-Ikram', 'meaning': 'Lord of Majesty and Generosity'},
    {'number': '86', 'arabic': 'الْمُقْسِطُ', 'transliteration': 'Al-Muqsit', 'meaning': 'The Equitable'},
    {'number': '87', 'arabic': 'الْجَامِعُ', 'transliteration': "Al-Jami'", 'meaning': 'The Gatherer'},
    {'number': '88', 'arabic': 'الْغَنِيُّ', 'transliteration': 'Al-Ghani', 'meaning': 'The Self-Sufficient'},
    {'number': '89', 'arabic': 'الْمُغْنِي', 'transliteration': 'Al-Mughni', 'meaning': 'The Enricher'},
    {'number': '90', 'arabic': 'الْمَانِعُ', 'transliteration': "Al-Mani'", 'meaning': 'The Withholder'},
    {'number': '91', 'arabic': 'الضَّارُ', 'transliteration': 'Ad-Darr', 'meaning': 'The Distressor'},
    {'number': '92', 'arabic': 'النَّافِعُ', 'transliteration': 'An-Nafi', 'meaning': 'The Propitious'},
    {'number': '93', 'arabic': 'النُّورُ', 'transliteration': 'An-Noor', 'meaning': 'The Light'},
    {'number': '94', 'arabic': 'الْهَادِي', 'transliteration': 'Al-Hadi', 'meaning': 'The Guide'},
    {'number': '95', 'arabic': 'الْبَدِيعُ', 'transliteration': 'Al-Badi', 'meaning': 'The Originator'},
    {'number': '96', 'arabic': 'الْبَاقِي', 'transliteration': 'Al-Baqi', 'meaning': 'The Everlasting'},
    {'number': '97', 'arabic': 'الْوَارِثُ', 'transliteration': 'Al-Warith', 'meaning': 'The Inheritor'},
    {'number': '98', 'arabic': 'الرَّشِيدُ', 'transliteration': 'Ar-Rasheed', 'meaning': 'The Rightly Guided'},
    {'number': '99', 'arabic': 'الصَّبُورُ', 'transliteration': 'As-Saboor', 'meaning': 'The Patient'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('99 Names of Allah')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _names.length,
        itemBuilder: (context, i) {
          final name = _names[i];
          return _NameCard(name: name, isDark: isDark, index: i);
        },
      ),
    );
  }
}

class _NameCard extends StatelessWidget {
  final Map<String, String> name;
  final bool isDark;
  final int index;
  const _NameCard({required this.name, required this.isDark, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDark ? AppColors.darkCard : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name['number']!,
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                name['arabic']!,
                style: GoogleFonts.scheherazadeNew(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                name['transliteration']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                name['meaning']!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 20 * (index > 15 ? 15 : index)));
  }
}
