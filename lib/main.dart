import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isReady = false;

  final List<Task> _tasks = [];
  final List<String> _notes = [];

  String _userName = 'Aman Kumar';
  final String _userEmail = 'aman.dev@college.com';
  final String _userStream = 'Class 12th - Science Stream';
  String _profileImage = defaultProfileImage;
  bool _isLocalImage = false;

  @override
  void initState() {
    super.initState();
    _loadAppState();
  }

  Future<void> _loadAppState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTasks = prefs.getStringList(StorageKeys.tasks);
      final savedNotes = prefs.getStringList(StorageKeys.notes);

      _tasks
        ..clear()
        ..addAll(
          savedTasks == null || savedTasks.isEmpty
              ? defaultTasks()
              : savedTasks
                    .map(
                      (item) => Task.fromJson(
                        jsonDecode(item) as Map<String, dynamic>,
                      ),
                    )
                    .toList(),
        );
      _sortTasks();

      _notes
        ..clear()
        ..addAll(savedNotes ?? const []);

      setState(() {
        _themeMode = _themeModeFromString(
          prefs.getString(StorageKeys.themeMode),
        );
        _currentLanguage =
            prefs.getString(StorageKeys.language) ?? _currentLanguage;
        _isLoggedIn = prefs.getBool(StorageKeys.isLoggedIn) ?? false;
        _userName = prefs.getString(StorageKeys.userName) ?? _userName;
        _profileImage =
            prefs.getString(StorageKeys.profileImage) ?? _profileImage;
        _isLocalImage = prefs.getBool(StorageKeys.isLocalImage) ?? false;
        _isReady = true;
      });
    } catch (_) {
      _tasks
        ..clear()
        ..addAll(defaultTasks());
      _sortTasks();

      if (mounted) {
        setState(() {
          _isReady = true;
        });
      }
    }
  }

  Future<void> _persistAppState() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(StorageKeys.themeMode, _themeMode.name),
      prefs.setString(StorageKeys.language, _currentLanguage),
      prefs.setBool(StorageKeys.isLoggedIn, _isLoggedIn),
      prefs.setString(StorageKeys.userName, _userName),
      prefs.setString(StorageKeys.profileImage, _profileImage),
      prefs.setBool(StorageKeys.isLocalImage, _isLocalImage),
      prefs.setStringList(
        StorageKeys.tasks,
        _tasks.map((task) => jsonEncode(task.toJson())).toList(),
      ),
      prefs.setStringList(StorageKeys.notes, List<String>.from(_notes)),
    ]);
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
    unawaited(_persistAppState());
  }

  void _toggleLanguage() {
    setState(() {
      _currentLanguage = _currentLanguage == 'English' ? 'Hindi' : 'English';
    });
    unawaited(_persistAppState());
  }

  void _updateProfile(String newName, String newImagePath, bool isLocal) {
    setState(() {
      _userName = newName.trim().isEmpty ? _userName : newName.trim();
      _profileImage = newImagePath;
      _isLocalImage = isLocal;
    });
    unawaited(_persistAppState());
  }

  void _addTask(Task task) {
    setState(() {
      _tasks.add(task);
      _sortTasks();
    });
    unawaited(_persistAppState());
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    unawaited(_persistAppState());
  }

  void _updateTask(int index, Task task) {
    setState(() {
      _tasks[index] = task;
      _sortTasks();
    });
    unawaited(_persistAppState());
  }

  void _toggleTaskCompletion(int index, bool completed) {
    setState(() {
      _tasks[index] = _tasks[index].copyWith(completed: completed);
      _sortTasks();
    });
    unawaited(_persistAppState());
  }

  void _addNote(String noteName) {
    setState(() {
      _notes.add(noteName);
    });
    unawaited(_persistAppState());
  }

  Future<void> _clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.themeMode);
    await prefs.remove(StorageKeys.language);
    await prefs.remove(StorageKeys.isLoggedIn);
    await prefs.remove(StorageKeys.userName);
    await prefs.remove(StorageKeys.profileImage);
    await prefs.remove(StorageKeys.isLocalImage);
    await prefs.remove(StorageKeys.tasks);
    await prefs.remove(StorageKeys.notes);

    _tasks
      ..clear()
      ..addAll(defaultTasks());
    _notes.clear();
    _sortTasks();

    setState(() {
      _themeMode = ThemeMode.light;
      _currentLanguage = 'English';
      _isLoggedIn = false;
      _userName = 'Aman Kumar';
      _profileImage = defaultProfileImage;
      _isLocalImage = false;
    });
  }

  void _setLoggedIn(bool value) {
    setState(() {
      _isLoggedIn = value;
    });
    unawaited(_persistAppState());
  }

  void _sortTasks() {
    _tasks.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) {
        return a.title.compareTo(b.title);
      }
      if (a.dueDate == null) {
        return 1;
      }
      if (b.dueDate == null) {
        return -1;
      }
      return a.dueDate!.compareTo(b.dueDate!);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: Colors.deepPurple.shade400),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Smart Student Organizer',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      locale: _currentLanguage == 'Hindi'
          ? const Locale('hi', 'IN')
          : const Locale('en', 'US'),
      supportedLocales: const [Locale('en', 'US'), Locale('hi', 'IN')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: Colors.deepPurple,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
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
              onLogout: () => _setLoggedIn(false),
              onAddTask: _addTask,
              onUpdateTask: _updateTask,
              onDeleteTask: _deleteTask,
              onToggleTaskCompletion: _toggleTaskCompletion,
              notes: _notes,
              onAddNote: _addNote,
              onClearAllData: _clearAllData,
            )
          : LoginScreen(
              onThemeToggle: _toggleTheme,
              onLanguageToggle: _toggleLanguage,
              currentMode: _themeMode,
              currentLanguage: _currentLanguage,
              onLogin: () => _setLoggedIn(true),
            ),
    );
  }
}

class StorageKeys {
  static const themeMode = 'theme_mode';
  static const language = 'language';
  static const isLoggedIn = 'is_logged_in';
  static const userName = 'user_name';
  static const profileImage = 'profile_image';
  static const isLocalImage = 'is_local_image';
  static const tasks = 'tasks';
  static const notes = 'notes';
}

const String defaultProfileImage = 'https://i.pravatar.cc/150?u=student';

ThemeMode _themeModeFromString(String? value) {
  switch (value) {
    case 'dark':
      return ThemeMode.dark;
    case 'light':
    default:
      return ThemeMode.light;
  }
}

List<Task> defaultTasks() {
  return [
    Task(
      title: 'Complete Flutter UI',
      desc: 'Build dashboard cards and polish navigation.',
      dueDate: DateTime.now().add(const Duration(days: 1)),
    ),
    Task(
      title: 'Revise Physics Notes',
      desc: 'Go through optics formulas for the weekly test.',
      dueDate: DateTime.now(),
      completed: true,
    ),
    Task(
      title: 'Upload Chemistry Assignment',
      desc: 'Attach PDF before the evening deadline.',
      dueDate: DateTime.now().add(const Duration(days: 3)),
    ),
  ];
}

class T {
  static String get(String key, String lang) {
    final localized = <String, Map<String, String>>{
      'English': {
        'app_title': 'Smart Organizer',
        'tagline': 'Your academic life, simplified',
        'welcome': 'Welcome back!',
        'pending': 'Pending',
        'done': 'Completed',
        'attendance': 'Attendance',
        'timer': 'Focus Timer',
        'timer_sub': 'Run a 25-minute study sprint',
        'timer_running': 'Session running',
        'timer_ready': 'Ready for your next deep-work block',
        'start': 'Start',
        'pause': 'Pause',
        'reset': 'Reset',
        'tasks': 'Tasks',
        'recent_tasks': 'Recent Tasks',
        'schedule': 'Schedule',
        'notes': 'Notes',
        'profile': 'Profile',
        'logout': 'Log Out',
        'full_name': 'Full Name',
        'save': 'Save Changes',
        'upload_note': 'Upload Note',
        'no_tasks': 'No tasks yet',
        'login_btn': 'LOGIN AS STUDENT',
        'task_name': 'Task Name',
        'task_date': 'Pick Date',
        'task_desc': 'Description',
        'task_mark_done': 'Mark as done',
        'task_mark_pending': 'Mark as pending',
        'task_due_today': 'Due today',
        'task_unscheduled': 'Unscheduled',
        'task_saved': 'Task added',
        'schedule_empty': 'No tasks planned for this day',
        'schedule_unscheduled': 'Unscheduled tasks',
        'notes_empty': 'Upload notes to keep study material handy',
        'today': 'Today',
        'upcoming': 'Upcoming',
      },
      'Hindi': {
        'app_title':
            '\u0938\u094d\u092e\u093e\u0930\u094d\u091f \u0911\u0930\u094d\u0917\u0928\u093e\u0907\u091c\u0930',
        'tagline':
            '\u0906\u092a\u0915\u0940 \u092a\u0922\u093c\u093e\u0908 \u0915\u0940 \u091c\u093f\u0902\u0926\u0917\u0940, \u0905\u092c \u0914\u0930 \u0906\u0938\u093e\u0928',
        'welcome':
            '\u0935\u093e\u092a\u0938 \u0938\u094d\u0935\u093e\u0917\u0924 \u0939\u0948!',
        'pending': '\u092c\u093e\u0915\u0940',
        'done': '\u092a\u0942\u0930\u093e',
        'attendance': '\u0909\u092a\u0938\u094d\u0925\u093f\u0924\u093f',
        'timer': '\u092b\u094b\u0915\u0938 \u091f\u093e\u0907\u092e\u0930',
        'timer_sub':
            '25 \u092e\u093f\u0928\u091f \u0915\u0940 \u0938\u094d\u091f\u0921\u0940 \u0938\u094d\u092a\u094d\u0930\u093f\u0902\u091f \u091a\u0932\u093e\u090f\u0902',
        'timer_running':
            '\u0938\u0947\u0936\u0928 \u091a\u0932 \u0930\u0939\u093e \u0939\u0948',
        'timer_ready':
            '\u0905\u0917\u0932\u0947 \u092b\u094b\u0915\u0938 \u0938\u0947\u0936\u0928 \u0915\u0947 \u0932\u093f\u090f \u0924\u0948\u092f\u093e\u0930',
        'start': '\u0936\u0941\u0930\u0942',
        'pause': '\u0930\u094b\u0915\u0947\u0902',
        'reset': '\u0930\u0940\u0938\u0947\u091f',
        'tasks': '\u0915\u093e\u0930\u094d\u092f',
        'recent_tasks':
            '\u0939\u093e\u0932 \u0915\u0947 \u0915\u093e\u0930\u094d\u092f',
        'schedule': '\u0938\u092e\u092f \u0938\u093e\u0930\u0923\u0940',
        'notes': '\u0928\u094b\u091f\u094d\u0938',
        'profile': '\u092a\u094d\u0930\u094b\u092b\u093e\u0907\u0932',
        'logout': '\u0932\u0949\u0917 \u0906\u0909\u091f',
        'full_name': '\u092a\u0942\u0930\u093e \u0928\u093e\u092e',
        'save': '\u0938\u0947\u0935 \u0915\u0930\u0947\u0902',
        'upload_note':
            '\u0928\u094b\u091f \u0905\u092a\u0932\u094b\u0921 \u0915\u0930\u0947\u0902',
        'no_tasks':
            '\u0905\u092d\u0940 \u0915\u094b\u0908 \u0915\u093e\u0930\u094d\u092f \u0928\u0939\u0940\u0902',
        'login_btn':
            '\u0938\u094d\u091f\u0942\u0921\u0947\u0902\u091f \u0915\u0947 \u0930\u0942\u092a \u092e\u0947\u0902 \u0932\u0949\u0917\u093f\u0928',
        'task_name':
            '\u0915\u093e\u0930\u094d\u092f \u0915\u093e \u0928\u093e\u092e',
        'task_date':
            '\u0924\u093e\u0930\u0940\u0916 \u091a\u0941\u0928\u0947\u0902',
        'task_desc': '\u0935\u093f\u0935\u0930\u0923',
        'task_mark_done':
            '\u092a\u0942\u0930\u093e \u091a\u093f\u0939\u094d\u0928\u093f\u0924 \u0915\u0930\u0947\u0902',
        'task_mark_pending':
            '\u092b\u093f\u0930 \u0938\u0947 \u092c\u093e\u0915\u0940 \u0915\u0930\u0947\u0902',
        'task_due_today':
            '\u0906\u091c \u0915\u0940 \u0921\u0947\u0921\u0932\u093e\u0907\u0928',
        'task_unscheduled':
            '\u092c\u093f\u0928\u093e \u0924\u093e\u0930\u0940\u0916 \u0915\u093e \u0915\u093e\u0930\u094d\u092f',
        'task_saved':
            '\u0915\u093e\u0930\u094d\u092f \u091c\u094b\u0921\u093c \u0926\u093f\u092f\u093e \u0917\u092f\u093e',
        'schedule_empty':
            '\u0907\u0938 \u0926\u093f\u0928 \u0915\u0947 \u0932\u093f\u090f \u0915\u094b\u0908 \u0915\u093e\u0930\u094d\u092f \u0928\u0939\u0940\u0902 \u0939\u0948',
        'schedule_unscheduled':
            '\u092c\u093f\u0928\u093e \u0924\u093e\u0930\u0940\u0916 \u0915\u0947 \u0915\u093e\u0930\u094d\u092f',
        'notes_empty':
            '\u0928\u094b\u091f\u094d\u0938 \u0905\u092a\u0932\u094b\u0921 \u0915\u0930\u0915\u0947 \u0938\u094d\u091f\u0921\u0940 \u092e\u0948\u091f\u0940\u0930\u093f\u092f\u0932 \u0924\u0948\u092f\u093e\u0930 \u0930\u0916\u0947\u0902',
        'today': '\u0906\u091c',
        'upcoming': '\u0906\u0928\u0947 \u0935\u093e\u0932\u093e',
      },
    };
    return localized[lang]?[key] ?? key;
  }
}

class LoginScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final VoidCallback onLanguageToggle;
  final VoidCallback onLogin;
  final ThemeMode currentMode;
  final String currentLanguage;

  const LoginScreen({
    super.key,
    required this.onThemeToggle,
    required this.onLanguageToggle,
    required this.currentMode,
    required this.currentLanguage,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = currentMode == ThemeMode.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.black, Colors.indigo.shade900]
                : [Colors.deepPurple.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_stories_rounded,
                  size: 100,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 24),
                Text(
                  T.get('app_title', currentLanguage),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  T.get('tagline', currentLanguage),
                  style: TextStyle(color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: onLogin,
                  child: Text(
                    T.get('login_btn', currentLanguage),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.translate,
                        color: Colors.deepPurple,
                      ),
                      onPressed: onLanguageToggle,
                    ),
                    IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                        color: Colors.deepPurple,
                      ),
                      onPressed: onThemeToggle,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  final List<Task> tasks;
  final List<String> notes;
  final VoidCallback onThemeToggle;
  final VoidCallback onLanguageToggle;
  final VoidCallback onLogout;
  final ThemeMode currentMode;
  final String currentLanguage;
  final String userName;
  final String userEmail;
  final String userStream;
  final String profileImage;
  final bool isLocalImage;
  final void Function(String, String, bool) onProfileUpdate;
  final void Function(Task) onAddTask;
  final void Function(int, Task) onUpdateTask;
  final void Function(int) onDeleteTask;
  final void Function(int, bool) onToggleTaskCompletion;
  final void Function(String) onAddNote;
  final Future<void> Function() onClearAllData;

  const MainShell({
    super.key,
    required this.tasks,
    required this.notes,
    required this.onThemeToggle,
    required this.onLanguageToggle,
    required this.currentMode,
    required this.currentLanguage,
    required this.userName,
    required this.userEmail,
    required this.userStream,
    required this.profileImage,
    required this.isLocalImage,
    required this.onProfileUpdate,
    required this.onLogout,
    required this.onAddTask,
    required this.onUpdateTask,
    required this.onDeleteTask,
    required this.onToggleTaskCompletion,
    required this.onAddNote,
    required this.onClearAllData,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      HomeScreen(
        tasks: widget.tasks,
        lang: widget.currentLanguage,
        userName: widget.userName,
      ),
      TasksScreen(
        tasks: widget.tasks,
        lang: widget.currentLanguage,
        onAdd: widget.onAddTask,
        onUpdate: widget.onUpdateTask,
        onDelete: widget.onDeleteTask,
        onToggleComplete: widget.onToggleTaskCompletion,
      ),
      ScheduleScreen(tasks: widget.tasks, lang: widget.currentLanguage),
      NotesScreen(
        lang: widget.currentLanguage,
        notes: widget.notes,
        onAddNote: widget.onAddNote,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          T.get('app_title', widget.currentLanguage),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate, size: 20),
            onPressed: widget.onLanguageToggle,
          ),
          IconButton(
            icon: Icon(
              widget.currentMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
              size: 20,
            ),
            onPressed: widget.onThemeToggle,
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  userName: widget.userName,
                  userEmail: widget.userEmail,
                  userStream: widget.userStream,
                  profileImage: widget.profileImage,
                  isLocalImage: widget.isLocalImage,
                  lang: widget.currentLanguage,
                  onProfileUpdate: widget.onProfileUpdate,
                  onLogout: widget.onLogout,
                  onClearAllData: widget.onClearAllData,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 12, left: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: buildProfileImage(
                  path: widget.profileImage,
                  isLocal: widget.isLocalImage,
                ),
              ),
            ),
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.deepPurple,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.check_circle_rounded),
            label: T.get('tasks', widget.currentLanguage),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month_rounded),
            label: T.get('schedule', widget.currentLanguage),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.sticky_note_2_rounded),
            label: T.get('notes', widget.currentLanguage),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<Task> tasks;
  final String lang;
  final String userName;

  const HomeScreen({
    super.key,
    required this.tasks,
    required this.lang,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final pendingTasks = tasks.where((task) => !task.completed).toList();
    final completedTasks = tasks.where((task) => task.completed).toList();
    final todayTasks = tasks
        .where((task) => isSameDay(task.dueDate, DateTime.now()))
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${T.get('welcome', lang)} $userName',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          Text(
            DateFormat('EEEE, d MMMM').format(DateTime.now()),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              _buildStatBox(
                T.get('pending', lang),
                '${pendingTasks.length}',
                Colors.orange,
              ),
              const SizedBox(width: 15),
              _buildStatBox(
                T.get('done', lang),
                '${completedTasks.length}',
                Colors.teal,
              ),
            ],
          ),
          const SizedBox(height: 25),
          FocusTimerCard(lang: lang),
          const SizedBox(height: 25),
          Text(
            T.get('recent_tasks', lang),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (tasks.isEmpty)
            Text(
              T.get('no_tasks', lang),
              style: const TextStyle(color: Colors.grey),
            )
          else
            Column(
              children: tasks.reversed.take(3).map((task) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Icon(
                      task.completed
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: task.completed ? Colors.teal : Colors.deepPurple,
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(task.dateLabel(lang)),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 25),
          _buildProgressBox(
            T.get('attendance', lang),
            '$todayTasks ${T.get('today', lang)}',
            tasks.isEmpty
                ? 0
                : (completedTasks.length / tasks.length).clamp(0, 1),
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBox(
    String title,
    String value,
    double progress,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                width: 150,
                child: LinearProgressIndicator(
                  value: progress,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class FocusTimerCard extends StatefulWidget {
  final String lang;

  const FocusTimerCard({super.key, required this.lang});

  @override
  State<FocusTimerCard> createState() => _FocusTimerCardState();
}

class _FocusTimerCardState extends State<FocusTimerCard> {
  static const int _sessionSeconds = 25 * 60;
  late int _remainingSeconds;
  Timer? _timer;

  bool get _isRunning => _timer?.isActive ?? false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _sessionSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {});
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
    setState(() {});
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() => _remainingSeconds = _sessionSeconds);
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    final progress = 1 - (_remainingSeconds / _sessionSeconds);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.hourglass_bottom_rounded,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      T.get('timer', widget.lang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      _isRunning
                          ? T.get('timer_running', widget.lang)
                          : T.get('timer_ready', widget.lang),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Text(
                '$minutes:$seconds',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            color: Colors.white,
            minHeight: 8,
            borderRadius: BorderRadius.circular(20),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple,
                  ),
                  onPressed: _toggleTimer,
                  child: Text(
                    _isRunning
                        ? T.get('pause', widget.lang)
                        : T.get('start', widget.lang),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                  onPressed: _resetTimer,
                  child: Text(T.get('reset', widget.lang)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TasksScreen extends StatelessWidget {
  final List<Task> tasks;
  final String lang;
  final void Function(Task) onAdd;
  final void Function(int, Task) onUpdate;
  final void Function(int) onDelete;
  final void Function(int, bool) onToggleComplete;

  const TasksScreen({
    super.key,
    required this.tasks,
    required this.lang,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tasks.isEmpty
          ? Center(child: Text(T.get('no_tasks', lang)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => AddTaskSheet(
                        lang: lang,
                        initialTask: task,
                        onSave: (updatedTask) => onUpdate(index, updatedTask),
                      ),
                    ),
                    leading: Checkbox(
                      value: task.completed,
                      onChanged: (value) =>
                          onToggleComplete(index, value ?? false),
                      activeColor: Colors.teal,
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text('${task.dateLabel(lang)}\n${task.desc}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => onDelete(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => AddTaskSheet(lang: lang, onSave: onAdd),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddTaskSheet extends StatefulWidget {
  final String lang;
  final void Function(Task) onSave;
  final Task? initialTask;

  const AddTaskSheet({
    super.key,
    required this.lang,
    required this.onSave,
    this.initialTask,
  });

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _date;

  bool get _isEditing => widget.initialTask != null;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    if (task != null) {
      _titleController.text = task.title;
      _descController.text = task.desc;
      _date = task.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isEditing ? 'Edit Task' : 'Add Task',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: T.get('task_name', widget.lang),
            ),
          ),
          ListTile(
            title: Text(
              _date == null
                  ? T.get('task_date', widget.lang)
                  : DateFormat('dd MMM, yyyy').format(_date!),
            ),
            leading: const Icon(Icons.calendar_month),
            onTap: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: _date ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime(2100),
              );
              if (selectedDate != null) {
                setState(() => _date = selectedDate);
              }
            },
          ),
          TextField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: T.get('task_desc', widget.lang),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.trim().isEmpty) {
                return;
              }

              widget.onSave(
                Task(
                  title: _titleController.text.trim(),
                  desc: _descController.text.trim(),
                  dueDate: _date,
                  completed: widget.initialTask?.completed ?? false,
                ),
              );
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isEditing
                          ? 'Task updated'
                          : T.get('task_saved', widget.lang),
                    ),
                  ),
                );
              }
            },
            child: Text(T.get('save', widget.lang)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class ScheduleScreen extends StatefulWidget {
  final List<Task> tasks;
  final String lang;

  const ScheduleScreen({super.key, required this.tasks, required this.lang});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final nextSevenDays = List<DateTime>.generate(
      7,
      (index) => DateTime.now().add(Duration(days: index)),
    );
    final selectedTasks = widget.tasks
        .where((task) => isSameDay(task.dueDate, _selectedDate))
        .toList();
    final unscheduledTasks = widget.tasks
        .where((task) => task.dueDate == null)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          T.get('upcoming', widget.lang),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: nextSevenDays.length,
            separatorBuilder: (_, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final day = nextSevenDays[index];
              final isSelected = isSameDay(day, _selectedDate);
              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => setState(() => _selectedDate = day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 76,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.deepPurple : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? Colors.deepPurple
                          : Colors.deepPurple.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE').format(day),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.deepPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('d').format(day),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          DateFormat('EEEE, dd MMMM').format(_selectedDate),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (selectedTasks.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(T.get('schedule_empty', widget.lang)),
            ),
          )
        else
          ...selectedTasks.map(
            (task) => TaskScheduleCard(task: task, lang: widget.lang),
          ),
        if (unscheduledTasks.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            T.get('schedule_unscheduled', widget.lang),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...unscheduledTasks.map(
            (task) => TaskScheduleCard(task: task, lang: widget.lang),
          ),
        ],
      ],
    );
  }
}

class TaskScheduleCard extends StatelessWidget {
  final Task task;
  final String lang;

  const TaskScheduleCard({super.key, required this.task, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: task.completed
              ? Colors.teal.withValues(alpha: 0.15)
              : Colors.orange.withValues(alpha: 0.15),
          child: Icon(
            task.completed ? Icons.check : Icons.schedule,
            color: task.completed ? Colors.teal : Colors.orange,
          ),
        ),
        title: Text(task.title),
        subtitle: Text(task.desc.isEmpty ? task.dateLabel(lang) : task.desc),
        trailing: Text(
          task.dateLabel(lang),
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userStream;
  final String profileImage;
  final bool isLocalImage;
  final String lang;
  final void Function(String, String, bool) onProfileUpdate;
  final VoidCallback onLogout;
  final Future<void> Function() onClearAllData;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userStream,
    required this.profileImage,
    required this.isLocalImage,
    required this.lang,
    required this.onProfileUpdate,
    required this.onLogout,
    required this.onClearAllData,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late String _currentImage;
  late bool _isLocal;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _currentImage = widget.profileImage;
    _isLocal = widget.isLocalImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _currentImage = image.path;
        _isLocal = true;
      });
    }
  }

  Future<void> _confirmClearAllData() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear all data?'),
          content: const Text(
            'This will remove saved tasks, notes, profile changes, theme, and language preferences.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (shouldClear == true && mounted) {
      await widget.onClearAllData();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All saved data has been cleared.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(T.get('profile', widget.lang))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundImage: buildProfileImage(
                      path: _currentImage,
                      isLocal: _isLocal,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: T.get('full_name', widget.lang),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                widget.onProfileUpdate(
                  _nameController.text,
                  _currentImage,
                  _isLocal,
                );
                Navigator.pop(context);
              },
              child: Text(T.get('save', widget.lang)),
            ),
            const SizedBox(height: 40),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(widget.userEmail),
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Stream'),
              subtitle: Text(widget.userStream),
            ),
            const SizedBox(height: 50),
            OutlinedButton(
              onPressed: widget.onLogout,
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              child: Text(T.get('logout', widget.lang)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _confirmClearAllData,
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear All Data'),
            ),
          ],
        ),
      ),
    );
  }
}

class NotesScreen extends StatefulWidget {
  final String lang;
  final List<String> notes;
  final void Function(String) onAddNote;

  const NotesScreen({
    super.key,
    required this.lang,
    required this.notes,
    required this.onAddNote,
  });

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      widget.onAddNote(result.files.single.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.notes.isEmpty
          ? Center(child: Text(T.get('notes_empty', widget.lang)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: widget.notes.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                    ),
                    title: Text(widget.notes[index]),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: _pickFile,
        icon: const Icon(Icons.upload_file, color: Colors.white),
        label: Text(
          T.get('upload_note', widget.lang),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class Task {
  final String title;
  final String desc;
  final DateTime? dueDate;
  final bool completed;

  const Task({
    required this.title,
    required this.desc,
    this.dueDate,
    this.completed = false,
  });

  Task copyWith({
    String? title,
    String? desc,
    DateTime? dueDate,
    bool? completed,
  }) {
    return Task(
      title: title ?? this.title,
      desc: desc ?? this.desc,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'desc': desc,
      'dueDate': dueDate?.toIso8601String(),
      'completed': completed,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'] as String? ?? '',
      desc: json['desc'] as String? ?? '',
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.tryParse(json['dueDate'] as String),
      completed: json['completed'] as bool? ?? false,
    );
  }

  String dateLabel(String lang) {
    if (dueDate == null) {
      return T.get('task_unscheduled', lang);
    }
    if (isSameDay(dueDate, DateTime.now())) {
      return T.get('task_due_today', lang);
    }
    return DateFormat('dd MMM, yyyy').format(dueDate!);
  }
}

ImageProvider buildProfileImage({required String path, required bool isLocal}) {
  if (path.trim().isEmpty) {
    return const NetworkImage(defaultProfileImage);
  }

  if (!isLocal || kIsWeb) {
    return NetworkImage(path);
  }

  final file = File(path);
  if (!file.existsSync()) {
    return const NetworkImage(defaultProfileImage);
  }
  return FileImage(file);
}

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
