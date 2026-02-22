class ProphetStoryModel {
  final String name;
  final String arabicName;
  final String suffix;
  final String story;
  final String lesson;

  const ProphetStoryModel({
    required this.name,
    required this.arabicName,
    required this.suffix,
    required this.story,
    required this.lesson,
  });
}

// Local data — expanded stories
const List<ProphetStoryModel> prophetStories = [
  ProphetStoryModel(
    name: 'Adam',
    arabicName: 'آدم',
    suffix: 'AS',
    story:
        'Allah created Adam (AS) from clay and breathed life into him. He was the first human being, created in the best form. Allah taught Adam the names of all things and commanded the angels to prostrate before him. Iblis refused out of arrogance and was expelled. Adam and Hawwa (Eve) lived in Paradise but were later sent to Earth after being tested. On Earth, Adam repented sincerely and Allah forgave him. He is considered the father of all mankind and the first prophet.',
    lesson: 'Humility before Allah, and that sincere repentance is always accepted.',
  ),
  ProphetStoryModel(
    name: 'Nuh',
    arabicName: 'نوح',
    suffix: 'AS',
    story:
        'Nuh (AS) called his people to worship Allah for nearly 950 years. Despite constant mockery and rejection, he did not lose faith. Under Allah\'s command, he built a great Ark. The great flood came and destroyed the disbelievers, while Nuh and the believers were saved. His son refused to board, choosing disbelief over salvation.',
    lesson: 'Perseverance in the face of rejection, and that family bonds cannot replace faith.',
  ),
  ProphetStoryModel(
    name: 'Ibrahim',
    arabicName: 'إبراهيم',
    suffix: 'AS',
    story:
        'Ibrahim (AS) is known as the "Friend of Allah" (Khalilullah). He smashed the idols of his people and was thrown into a great fire, but Allah made it cool and safe. He was commanded to sacrifice his son Ismail — and both submitted — but Allah replaced the sacrifice with a ram. He built the Kaaba with his son Ismail in Makkah.',
    lesson: 'Complete surrender to Allah\'s will and trust in His plan (Tawakkul).',
  ),
  ProphetStoryModel(
    name: 'Musa',
    arabicName: 'موسى',
    suffix: 'AS',
    story:
        'Musa (AS) was born at a time when Pharaoh was killing newborn Israelite boys. His mother placed him in a basket on the Nile, and he was raised in Pharaoh\'s palace. Allah chose him as a prophet and gave him the miracle of the staff. He confronted Pharaoh and led Bani Israel out of Egypt. The Red Sea parted for them and swallowed Pharaoh\'s army. He received the Torah on Mount Sinai.',
    lesson: 'Allah\'s plan operates in mysterious ways, and truth always overcomes tyranny.',
  ),
  ProphetStoryModel(
    name: 'Yusuf',
    arabicName: 'يوسف',
    suffix: 'AS',
    story:
        'Yusuf (AS) had a prophetic dream as a child. Out of jealousy, his brothers threw him into a well. He was sold into slavery in Egypt, falsely imprisoned, yet never lost his faith. Allah blessed him with the ability to interpret dreams, which eventually led to him becoming the Minister of Egypt. He forgave his brothers who had wronged him, and was reunited with his father Yaqub (AS).',
    lesson: 'Patience (Sabr), chastity, and forgiveness lead to divine reward.',
  ),
  ProphetStoryModel(
    name: 'Muhammad',
    arabicName: 'محمد',
    suffix: 'SAW',
    story:
        'Muhammad (SAW) was born in Makkah in 570 CE. Known as Al-Amin (the Trustworthy) before prophethood, he received the first revelation in the Cave of Hira at age 40. For 23 years he preached Islam, facing persecution before migrating to Madinah — the Hijra. He united the Arabian Peninsula under Islam, performed Hajj, and delivered the Farewell Sermon. He is the Seal of the Prophets.',
    lesson: 'The greatest example of character, mercy, justice, and devotion to Allah.',
  ),
];
