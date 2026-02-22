# NoorWeb ✨

A beautiful, premium, and fully-featured Islamic companion app built with Flutter.

NoorWeb is designed to be the ultimate daily tool for Muslims, featuring a visually stunning UI with custom Arabic typography, dark/light mode support, and an emerald/gold design system. 

## 🌟 Premium Features

- **📖 Quran Majeed:** Read the complete Quran with authentic Arabic Waqf (end-of-ayah) markers securely centered. Includes offline **Mishary Rashid Alafasy audio downloading**, text sizing, and instant local Surah searching.
- **🕋 Prayer Times:** Automatic location-based prayer timings with a live countdown to the next prayer, leveraging the AlAdhan API.
- **📿 Digital Tasbeeh:** A gorgeous, tactile Tasbeeh counter featuring haptic feedback, 3D animated dragging beads, standard presets (SubhanAllah, Alhamdulillah, etc.), and **Custom Dhikr** creation.
- **📚 Hadith Collection:** Read complete Hadith books in Arabic and Urdu. Features collapsible cards, search functionality by keyword or Hadith number, and pinned headers for easy navigation.
- **🧭 Qibla Finder:** A beautifully animated compass pointing precisely towards the Kaaba.
- **🌙 Ramadan & Fasting:** Real-time Sehri and Iftar countdowns.
- **✨ 99 Names of Allah:** Asma-ul-Husna displayed in a clean, legible grid.
- **🧮 Zakat Calculator:** Easily compute your Nisab and annual Zakat obligations.
- **📅 Islamic Calendar:** Hijri date tracking and conversions.

## 📸 Screenshots
*(Add your screenshots here before publishing!)*

## 🛠️ Tech Stack & Architecture

- **Framework:** Flutter (Dart)
- **State Management:** BLoC (Business Logic Component) Pattern
- **Local Storage:** SharedPreferences & path_provider (for offline audio)
- **Networking:** Dio (AlQuran Cloud, AlAdhan, and FawazAhmed CDN APIs)
- **Audio:** audioplayers for immersive MP3 playback
- **Design:** Custom Google Fonts (Amiri, Noto Nastaliq Urdu, Inter), flutter_animate for micro-interactions.

## 🚀 Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/noor_app.git
   cd noor_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## 🤝 Contributing
Contributions, issues, and feature requests are welcome! Feel free to check the issues page.

## 📝 License
This project is licensed under the MIT License.