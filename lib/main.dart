import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStore.instance.init();
  runApp(const TarikhApp());
}

class AppPrefs extends ChangeNotifier {
  bool dark = true;
  String language = 'bn';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    dark = prefs.getBool('dark') ?? true;
    language = prefs.getString('language') ?? 'bn';
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    dark = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark', value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    language = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
    notifyListeners();
  }
}

final appPrefs = AppPrefs();

class LocalStore {
  LocalStore._();
  static final instance = LocalStore._();
  Database? _db;

  Future<void> init() async {
    final path = p.join(await getDatabasesPath(), 'tarikh.db');
    _db = await openDatabase(path, version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            category TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      });
  }

  Future<void> addNote(String title, String body, String category) async {
    await _db!.insert('notes', {
      'title': title, 'body': body, 'category': category,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, Object?>>> notes() async =>
      _db!.query('notes', orderBy: 'created_at DESC');

  Future<void> deleteNote(int id) async =>
      _db!.delete('notes', where: 'id = ?', whereArgs: [id]);
}

class TarikhApp extends StatefulWidget {
  const TarikhApp({super.key});
  @override
  State<TarikhApp> createState() => _TarikhAppState();
}

class _TarikhAppState extends State<TarikhApp> {
  @override
  void initState() {
    super.initState();
    appPrefs.load().then((_) { if (mounted) setState(() {}); });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appPrefs,
      builder: (_, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TARIKH',
        themeMode: appPrefs.dark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF78833B), brightness: Brightness.light), useMaterial3: true),
        darkTheme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF78833B), brightness: Brightness.dark), useMaterial3: true),
        home: const SplashScreen(),
      ),
    );
  }
}

const categories = [
  ('rashidun', 'খুলাফায়ে রাশেদিন', 'The Rightly Guided Caliphs', '☪'),
  ('umayyad', 'উমাইয়া খিলাফত', 'Umayyad Caliphate', '🏛'),
  ('abbasid', 'আব্বাসীয় খিলাফত', 'Abbasid Caliphate', '📜'),
  ('fatimid', 'ফাতেমীয় খিলাফত', 'Fatimid Caliphate', '🏰'),
  ('andalus', 'আন্দালুসের মুসলিম শাসন', 'Muslim Rule in Al-Andalus', '🕌'),
  ('ottoman', 'উসমানীয় খিলাফত', 'Ottoman Caliphate', '🌙'),
  ('indian', 'ভারতীয় উপমহাদেশে মুসলিম শাসন', 'Muslim Rule in the Indian Subcontinent', '🗺'),
  ('bengal', 'বাংলায় মুসলিম শাসন', 'Muslim Rule in Bengal', '📚'),
];

String tr(String bn, String en) => appPrefs.language == 'bn' ? bn : en;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF75B8E8),
    body: Stack(fit: StackFit.expand, children: [
      Align(alignment: Alignment.topCenter, child: Container(
        height: 250,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF78833B), Color(0xFF8A542F)], begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.vertical(bottom: Radius.elliptical(500, 170)),
        ),
      )),
      Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('T', style: TextStyle(fontSize: 150, height: 1, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Color(0xFFFFF8E8), shadows: [Shadow(color: Colors.black26, blurRadius: 12, offset: Offset(2, 5))])),
        const SizedBox(height: 12),
        const Text('TARIKH', style: TextStyle(fontSize: 38, letterSpacing: 9, fontWeight: FontWeight.bold, color: Color(0xFFFFD447))),
      ])),
    ]),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String institutionType = 'school';
  final institution = TextEditingController();
  final grade = TextEditingController();

  @override
  void dispose() { institution.dispose(); grade.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('TARIKH')),
    body: Padding(padding: const EdgeInsets.all(22), child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 28),
        Text(tr('শিক্ষার্থী প্রবেশ', 'Student Entry'), style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 18),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'madrasa', label: Text(tr('মাদ্রাসা', 'Madrasa'))),
            ButtonSegment(value: 'school', label: Text(tr('স্কুল', 'School'))),
          ],
          selected: {institutionType},
          onSelectionChanged: (v) => setState(() => institutionType = v.first),
        ),
        const SizedBox(height: 16),
        TextField(controller: institution, decoration: InputDecoration(labelText: tr('প্রতিষ্ঠানের নাম', 'Institution name'), border: const OutlineInputBorder())),
        const SizedBox(height: 14),
        TextField(controller: grade, decoration: InputDecoration(labelText: tr('শ্রেণি', 'Class / Grade'), border: const OutlineInputBorder())),
        const Spacer(),
        FilledButton(onPressed: () {
          if (institution.text.trim().isEmpty || grade.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('প্রতিষ্ঠানের নাম ও শ্রেণি লিখুন', 'Enter institution and grade'))));
            return;
          }
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(
            institution: institution.text.trim(), grade: grade.text.trim(), type: institutionType)));
        }, child: Text(tr('প্রবেশ করুন', 'Continue'))),
        const SizedBox(height: 18),
        const Text('Offline mode • No account verification', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
      ],
    )),
  );
}

class HomeScreen extends StatelessWidget {
  final String institution, grade, type;
  const HomeScreen({super.key, required this.institution, required this.grade, required this.type});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('TARIKH'), actions: [
      IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
      PopupMenuButton<String>(onSelected: (v) {
        if (v == 'admin') Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminGate()));
      }, itemBuilder: (_) => [PopupMenuItem(value: 'admin', child: Text(tr('অ্যাডমিন', 'Admin')))]),
    ]),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Text(tr('ইসলামের ইতিহাস ও সভ্যতা', 'Islamic History & Civilization'), style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 5),
      Text('$institution • ${tr('শ্রেণি', 'Class')} $grade', style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 18),
      ...categories.map((c) => Card(child: ListTile(
        leading: CircleAvatar(child: Text(c.$4)),
        title: Text(tr(c.$2, c.$3)),
        subtitle: Text(tr('শাসক, সময়কাল ও ঐতিহাসিক ঘটনা', 'Rulers, periods and historical events')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryScreen(category: c))),
      ))),
    ]),
  );
}

class CategoryScreen extends StatelessWidget {
  final (String, String, String, String) category;
  const CategoryScreen({super.key, required this.category});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr(category.$2, category.$3))),
    body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(
      tr('এই বিভাগের যাচাইকৃত শাসক তালিকা, জীবনী ও সময়রেখা এখানে যুক্ত হবে।\\n\\nপ্রতিটি তথ্যের সঙ্গে ঐতিহাসিক সূত্র ও তারিখের মতভেদ উল্লেখ করা হবে।',
         'Verified ruler lists, biographies and timelines for this section will appear here.\\n\\nHistorical sources and date disagreements will be documented.'),
      textAlign: TextAlign.center,
    ))),
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr('সেটিংস', 'Settings'))),
    body: ListView(children: [
      SwitchListTile(title: Text(tr('ডার্ক মোড', 'Dark mode')), value: appPrefs.dark, onChanged: appPrefs.setDark),
      ListTile(title: Text(tr('ভাষা', 'Language')), trailing: DropdownButton<String>(
        value: appPrefs.language, items: const [DropdownMenuItem(value: 'bn', child: Text('বাংলা')), DropdownMenuItem(value: 'en', child: Text('English'))],
        onChanged: (v) { if (v != null) appPrefs.setLanguage(v); },
      )),
    ]),
  );
}

class AdminGate extends StatefulWidget {
  const AdminGate({super.key});
  @override
  State<AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<AdminGate> {
  final pin = TextEditingController();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr('অ্যাডমিন প্রবেশ', 'Admin access'))),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Text(tr('প্রাথমিক ডেমো PIN: 2468 (প্রথম চালুর পর পরিবর্তন করতে হবে)', 'Demo PIN: 2468 (change before real use)')),
      const SizedBox(height: 12),
      TextField(controller: pin, obscureText: true, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Admin PIN', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      FilledButton(onPressed: () {
        if (pin.text == '2468') Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
        else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect PIN')));
      }, child: Text(tr('প্রবেশ', 'Enter'))),
    ])),
  );
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final title = TextEditingController(), body = TextEditingController();
  String category = 'rashidun';
  List<Map<String, Object?>> notes = [];

  Future<void> refresh() async { notes = await LocalStore.instance.notes(); if (mounted) setState(() {}); }
  @override
  void initState() { super.initState(); refresh(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr('লোকাল অ্যাডমিন প্যানেল', 'Local Admin Panel'))),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      TextField(controller: title, decoration: InputDecoration(labelText: tr('শিরোনাম', 'Title'))),
      TextField(controller: body, minLines: 3, maxLines: 6, decoration: InputDecoration(labelText: tr('তথ্য / জীবনী', 'Content / biography'))),
      DropdownButton<String>(value: category, isExpanded: true, items: categories.map((c) => DropdownMenuItem(value: c.$1, child: Text(tr(c.$2, c.$3)))).toList(), onChanged: (v) => setState(() => category = v ?? category)),
      FilledButton(onPressed: () async {
        if (title.text.trim().isEmpty || body.text.trim().isEmpty) return;
        await LocalStore.instance.addNote(title.text.trim(), body.text.trim(), category);
        title.clear(); body.clear(); await refresh();
      }, child: Text(tr('তথ্য সংরক্ষণ', 'Save entry'))),
      const Divider(height: 30),
      Text(tr('সংরক্ষিত তথ্য', 'Saved entries'), style: Theme.of(context).textTheme.titleLarge),
      ...notes.map((n) => Card(child: ListTile(
        title: Text(n['title'] as String),
        subtitle: Text((n['body'] as String), maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async { await LocalStore.instance.deleteNote(n['id'] as int); await refresh(); }),
      ))),
    ]),
  );
}
