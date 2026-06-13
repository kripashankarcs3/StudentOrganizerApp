import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const StudentOrganizerApp());
}

class StudentOrganizerApp extends StatefulWidget {
  const StudentOrganizerApp({super.key});

  @override
  State<StudentOrganizerApp> createState() => _StudentOrganizerAppState();
}

class _StudentOrganizerAppState extends State<StudentOrganizerApp> {
  ThemeMode _themeMode = ThemeMode.light;
  String _currentLanguage = 'English';
  bool _isLoggedIn = false;

  // Global State for Tasks
  final List<Task> _tasks = [
    Task(title: "Complete Flutter UI", desc: "Build Dashboard Cards", date: "24 Oct, 2023"),
  ];

  // Profile Data
  String _userName = "Aman Kumar";
  String _userEmail = "aman.dev@college.com";
  String _userStream = "Class 12th • Science Stream";
  String _profileImage = 'https://i.pravatar.cc/150?u=student';
  bool _isLocalImage = false;

  void _toggleTheme() {
    setState(() => _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }

  void _toggleLanguage() {
    setState(() => _currentLanguage = _currentLanguage == 'English' ? 'Hindi' : 'English');
  }

  void _updateProfile(String newName, String newImagePath, bool isLocal) {
    setState(() {
      _userName = newName;
      _profileImage = newImagePath;
      _isLocalImage = isLocal;
    });
  }

  void _addTask(Task t) {
    setState(() => _tasks.add(t));
  }

  void _deleteTask(int index) {
    setState(() => _tasks.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Student Organizer',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      locale: _currentLanguage == 'Hindi' ? const Locale('hi', 'IN') : const Locale('en', 'US'),
      supportedLocales: const [Locale('en', 'US'), Locale('hi', 'IN')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, primary: Colors.deepPurple),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, elevation: 0),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
      ),
      home: _isLoggedIn 
          ? MainShell(
              tasks: _tasks,
              onThemeToggle: _toggleTheme,
              onLanguageToggle: _toggleLanguage,
              currentMode: _themeMode,
              currentLanguage: _currentLanguage,
              userName: _userName,
              userEmail: _userEmail,
              userStream: _userStream,
              profileImage: _profileImage,
              isLocalImage: _isLocalImage,
              onProfileUpdate: _updateProfile,
              onLogout: () => setState(() => _isLoggedIn = false),
              onAddTask: _addTask,
              onDeleteTask: _deleteTask,
            )
          : LoginScreen(
              onThemeToggle: _toggleTheme,
              onLanguageToggle: _toggleLanguage,
              currentMode: _themeMode,
              currentLanguage: _currentLanguage,
              onLogin: () => setState(() => _isLoggedIn = true),
            ),
    );
  }
}

class T {
  static String get(String key, String lang) {
    final Map<String, Map<String, String>> localized = {
      'English': {
        'app_title': 'Smart Organizer',
        'welcome': 'Welcome Back! 🌟',
        'summary': 'Daily Summary',
        'pending': 'Pending',
        'done': 'Completed',
        'attendance': 'Attendance',
        'timer': 'Focus Timer',
        'timer_sub': '25 mins study session',
        'tasks': 'Tasks',
        'recent_tasks': 'Recent Tasks',
        'schedule': 'Schedule',
        'notes': 'Notes',
        'profile': 'Profile',
        'logout': 'Log Out',
        'edit_profile': 'Edit Profile',
        'full_name': 'Full Name',
        'save': 'Save Changes',
        'upload_note': 'Upload Note',
        'no_tasks': 'No tasks yet',
        'login_btn': 'LOGIN AS STUDENT',
        'task_name': 'Task Name',
        'task_date': 'Pick Date',
        'task_desc': 'Description',
        'no_date': 'No date',
      },
      'Hindi': {
        'app_title': 'स्मार्ट ऑर्गनाइज़र',
        'welcome': 'स्वागत है! 🌟',
        'summary': 'दैनिक सारांश',
        'pending': 'बाकी',
        'done': 'पूरा',
        'attendance': 'उपस्थिति',
        'timer': 'फोकस टाइमर',
        'timer_sub': '25 मिनट पढ़ाई',
        'tasks': 'कार्य',
        'recent_tasks': 'हाल के कार्य',
        'schedule': 'समय सारिणी',
        'notes': 'नोट्स',
        'profile': 'प्रोफ़ाइल',
        'logout': 'लॉग आउट',
        'edit_profile': 'प्रोफ़ाइल बदलें',
        'full_name': 'पूरा नाम',
        'save': 'सहेजें',
        'upload_note': 'नोट अपलोड करें',
        'no_tasks': 'कोई कार्य नहीं',
        'login_btn': 'लॉगिन करें',
        'task_name': 'कार्य का नाम',
        'task_date': 'तारीख चुनें',
        'task_desc': 'विवरण',
        'no_date': 'तारीख नहीं',
      }
    };
    return localized[lang]?[key] ?? key;
  }
}

class LoginScreen extends StatelessWidget {
  final VoidCallback onThemeToggle, onLanguageToggle, onLogin;
  final ThemeMode currentMode;
  final String currentLanguage;

  const LoginScreen({super.key, required this.onThemeToggle, required this.onLanguageToggle, required this.currentMode, required this.currentLanguage, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    bool isDark = currentMode == ThemeMode.dark;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark ? [Colors.black, Colors.indigo.shade900] : [Colors.deepPurple.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_stories_rounded, size: 100, color: Colors.deepPurple),
            const SizedBox(height: 24),
            Text(T.get('app_title', currentLanguage), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const Text("Your Academic Life, Simplified", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: onLogin,
              child: Text(T.get('login_btn', currentLanguage), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(icon: const Icon(Icons.translate, color: Colors.deepPurple), onPressed: onLanguageToggle),
              IconButton(icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: Colors.deepPurple), onPressed: onThemeToggle),
            ])
          ],
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  final List<Task> tasks;
  final VoidCallback onThemeToggle, onLanguageToggle, onLogout;
  final ThemeMode currentMode;
  final String currentLanguage, userName, userEmail, userStream, profileImage;
  final bool isLocalImage;
  final Function(String, String, bool) onProfileUpdate;
  final Function(Task) onAddTask;
  final Function(int) onDeleteTask;

  const MainShell({super.key, required this.tasks, required this.onThemeToggle, required this.onLanguageToggle, required this.currentMode, required this.currentLanguage, required this.userName, required this.userEmail, required this.userStream, required this.profileImage, required this.isLocalImage, required this.onProfileUpdate, required this.onLogout, required this.onAddTask, required this.onDeleteTask});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(tasks: widget.tasks, lang: widget.currentLanguage),
      TasksScreen(tasks: widget.tasks, lang: widget.currentLanguage, onAdd: widget.onAddTask, onDelete: widget.onDeleteTask),
      Center(child: Text(T.get('schedule', widget.currentLanguage), style: const TextStyle(fontSize: 20))),
      NotesScreen(lang: widget.currentLanguage),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(T.get('app_title', widget.currentLanguage), style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.translate, size: 20), onPressed: widget.onLanguageToggle),
          IconButton(icon: Icon(widget.currentMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode, size: 20), onPressed: widget.onThemeToggle),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userName: widget.userName, userEmail: widget.userEmail, userStream: widget.userStream, profileImage: widget.profileImage, isLocalImage: widget.isLocalImage, lang: widget.currentLanguage, onProfileUpdate: widget.onProfileUpdate, onLogout: widget.onLogout))),
            child: Padding(
              padding: const EdgeInsets.only(right: 12, left: 8),
              child: CircleAvatar(
                radius: 16, 
                backgroundImage: widget.isLocalImage ? FileImage(File(widget.profileImage)) as ImageProvider : NetworkImage(widget.profileImage),
              ),
            ),
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: Colors.deepPurple,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Home"),
          BottomNavigationBarItem(icon: const Icon(Icons.check_circle_rounded), label: T.get('tasks', widget.currentLanguage)),
          BottomNavigationBarItem(icon: const Icon(Icons.calendar_month_rounded), label: T.get('schedule', widget.currentLanguage)),
          BottomNavigationBarItem(icon: const Icon(Icons.sticky_note_2_rounded), label: T.get('notes', widget.currentLanguage)),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<Task> tasks;
  final String lang;
  const HomeScreen({super.key, required this.tasks, required this.lang});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(T.get('welcome', lang), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          Text(DateFormat('EEEE, d MMMM').format(DateTime.now()), style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 25),
          Row(children: [
            _buildStatBox(T.get('pending', lang), "${tasks.length}", Colors.orange),
            const SizedBox(width: 15),
            _buildStatBox(T.get('done', lang), "12", Colors.teal),
          ]),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700]), borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              const Icon(Icons.hourglass_empty_rounded, color: Colors.white, size: 40),
              const SizedBox(width: 15),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(T.get('timer', lang), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text(T.get('timer_sub', lang), style: const TextStyle(color: Colors.white70)),
              ]),
              const Spacer(),
              const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 45),
            ]),
          ),
          const SizedBox(height: 25),
          Text(T.get('recent_tasks', lang), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (tasks.isEmpty) 
            Text(T.get('no_tasks', lang), style: const TextStyle(color: Colors.grey))
          else 
            Column(children: tasks.reversed.take(3).map((t) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.task_alt, color: Colors.deepPurple),
                title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(t.date),
              ),
            )).toList()),
          const SizedBox(height: 25),
          _buildProgressBox(T.get('attendance', lang), "85%", 0.85, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String value, Color color) {
    return Expanded(child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.2))), child: Column(children: [Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)), Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color))])));
  }

  Widget _buildProgressBox(String title, String val, double prog, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(width: 150, child: LinearProgressIndicator(value: prog, color: color, backgroundColor: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10))),
          ]),
          Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}

class TasksScreen extends StatelessWidget {
  final List<Task> tasks;
  final String lang;
  final Function(Task) onAdd;
  final Function(int) onDelete;
  const TasksScreen({super.key, required this.tasks, required this.lang, required this.onAdd, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tasks.isEmpty 
          ? Center(child: Text(T.get('no_tasks', lang))) 
          : ListView.builder(
              padding: const EdgeInsets.all(20), 
              itemCount: tasks.length, 
              itemBuilder: (context, i) => Card(
                margin: const EdgeInsets.only(bottom: 12), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), 
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.deepPurple, child: Icon(Icons.assignment_rounded, color: Colors.white)), 
                  title: Text(tasks[i].title, style: const TextStyle(fontWeight: FontWeight.bold)), 
                  subtitle: Text("${tasks[i].date}\n${tasks[i].desc}"), 
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => onDelete(i),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.deepPurple, onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => _AddTaskSheet(lang: lang, onAdd: onAdd)), child: const Icon(Icons.add, color: Colors.white)),
    );
  }
}

class _AddTaskSheet extends StatefulWidget {
  final String lang;
  final Function(Task) onAdd;
  const _AddTaskSheet({required this.lang, required this.onAdd});
  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}
class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _t = TextEditingController();
  final _d = TextEditingController();
  DateTime? _date;
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20), child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: _t, decoration: InputDecoration(labelText: T.get('task_name', widget.lang))), ListTile(title: Text(_date == null ? T.get('task_date', widget.lang) : DateFormat('dd MMM, yyyy').format(_date!)), leading: const Icon(Icons.calendar_month), onTap: () async { final res = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100)); if (res != null) setState(() => _date = res); }), TextField(controller: _d, decoration: InputDecoration(labelText: T.get('task_desc', widget.lang))), const SizedBox(height: 20), ElevatedButton(onPressed: () { if (_t.text.isNotEmpty) { widget.onAdd(Task(title: _t.text, desc: _d.text, date: _date == null ? "" : DateFormat('dd MMM, yyyy').format(_date!))); Navigator.pop(context); } }, child: Text(T.get('save', widget.lang))), const SizedBox(height: 20)]));
  }
}

class ProfileScreen extends StatefulWidget {
  final String userName, userEmail, userStream, profileImage;
  final bool isLocalImage;
  final String lang;
  final Function(String, String, bool) onProfileUpdate;
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.userName, required this.userEmail, required this.userStream, required this.profileImage, required this.isLocalImage, required this.lang, required this.onProfileUpdate, required this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  String? _currentImg;
  bool _isLocal = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.userName);
    _currentImg = widget.profileImage;
    _isLocal = widget.isLocalImage;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() { _currentImg = img.path; _isLocal = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(T.get('profile', widget.lang))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(children: [
          Center(child: Stack(children: [
            CircleAvatar(radius: 65, backgroundImage: _isLocal ? FileImage(File(_currentImg!)) as ImageProvider : NetworkImage(_currentImg!)),
            Positioned(bottom: 0, right: 0, child: CircleAvatar(backgroundColor: Colors.deepPurple, child: IconButton(icon: const Icon(Icons.camera_alt, color: Colors.white), onPressed: _pickImage))),
          ])),
          const SizedBox(height: 30),
          TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: T.get('full_name', widget.lang), border: const OutlineInputBorder())),
          const SizedBox(height: 30),
          ElevatedButton(onPressed: () { widget.onProfileUpdate(_nameCtrl.text, _currentImg!, _isLocal); Navigator.pop(context); }, child: Text(T.get('save', widget.lang))),
          const SizedBox(height: 40),
          ListTile(leading: const Icon(Icons.email), title: const Text("Email"), subtitle: Text(widget.userEmail)),
          ListTile(leading: const Icon(Icons.school), title: const Text("Stream"), subtitle: Text(widget.userStream)),
          const SizedBox(height: 50),
          OutlinedButton(onPressed: widget.onLogout, style: OutlinedButton.styleFrom(foregroundColor: Colors.red), child: Text(T.get('logout', widget.lang))),
        ]),
      ),
    );
  }
}

class NotesScreen extends StatefulWidget {
  final String lang;
  const NotesScreen({super.key, required this.lang});
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}
class _NotesScreenState extends State<NotesScreen> {
  final List<String> _notes = [];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) setState(() => _notes.add(result.files.single.name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _notes.isEmpty ? Center(child: Text(T.get('notes', widget.lang))) : ListView.builder(padding: const EdgeInsets.all(20), itemCount: _notes.length, itemBuilder: (context, i) => Card(child: ListTile(leading: const Icon(Icons.picture_as_pdf, color: Colors.red), title: Text(_notes[i])))),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple, 
        foregroundColor: Colors.white, // Text color visible hone ke liye
        onPressed: _pickFile, 
        icon: const Icon(Icons.upload_file, color: Colors.white), 
        label: Text(T.get('upload_note', widget.lang), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
      ),
    );
  }
}

class Task {
  final String title, desc, date;
  Task({required this.title, required this.desc, required this.date});
}
