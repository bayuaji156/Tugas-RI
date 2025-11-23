import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Config
import 'config/theme.dart';

// Providers
import 'providers/schedule_provider.dart';

// Screens
import 'screens/splash/splash_screen.dart';
import 'screens/auth/auth_screens.dart';
import 'screens/menu/main_menu_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/timesync/timesync_screen.dart';
import 'screens/schedule_safe/schedule_safe_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const GrowPlannerApp());
}

class GrowPlannerApp extends StatelessWidget {
  const GrowPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        // Tambahkan provider lain di sini jika diperlukan
      ],
      child: MaterialApp(
        title: 'GrowPlanner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/main-menu': (context) => const MainMenuScreen(),
          '/home': (context) => const HomeScreen(),
          '/timesync': (context) => const TimeSyncScreen(),
          '/schedule-safe': (context) => const ScheduleSafeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/profile-detail': (context) => const ProfileDetailScreen(),
        },
      ),
    );
  }
}

/*
=================================================================
UPDATED FOLDER STRUCTURE:
=================================================================

lib/
├── main.dart
├── config/
│   └── theme.dart
├── models/
│   ├── task.dart (User, Task models)
│   └── schedule.dart (Schedule, ScheduleConflict models)
├── providers/
│   └── schedule_provider.dart (ScheduleProvider)
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── auth/
│   │   └── auth_screens.dart (UPDATED - navigate to main-menu)
│   ├── menu/
│   │   ├── main_menu_screen.dart (NEW - Animated menu)
│   │   └── simple_menu_screen.dart (NEW - Simple menu alternative)
│   ├── home/
│   │   └── home_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── task/
│   │   └── task_list_screen.dart
│   ├── timesync/
│   │   └── timesync_screen.dart
│   ├── schedule_safe/
│   │   └── schedule_safe_screen.dart
│   └── profile/
│       └── profile_screen.dart
└── widgets/
    └── reminder_dialog.dart

=================================================================
NEW NAVIGATION FLOW:
=================================================================

Splash Screen
    ↓
Onboarding Screen
    ↓
Login Screen
    ↓
🆕 Main Menu Screen (NEW)
    ├→ Dashboard (Navigate to Home with bottom nav)
    ├→ TimeSync (Navigate directly)
    └→ ConflictDetails (Navigate to ScheduleSafe)

=================================================================
FILES TO CREATE/UPDATE:
=================================================================

1. CREATE: lib/screens/menu/main_menu_screen.dart
   - Animated menu with slide transitions
   - 3 main options: Dashboard, TimeSync, ConflictDetails
   - Logout button

2. CREATE: lib/screens/menu/simple_menu_screen.dart (Optional)
   - Simpler version, closer to mockup design
   - Less animations, more straightforward

3. UPDATE: lib/screens/auth/auth_screens.dart
   - Login now navigates to '/main-menu' instead of '/home'
   - Register also goes to '/main-menu'

4. UPDATE: lib/main.dart
   - Added '/main-menu' route
   - Import MainMenuScreen

=================================================================
FEATURES:
=================================================================

✅ Main Menu Screen setelah login
✅ 3 Menu utama: Dashboard, TimeSync, ConflictDetails
✅ Animated transitions (slide + fade)
✅ Logout confirmation dialog
✅ Gradient background matching theme
✅ Clean navigation flow
✅ Back to login on logout

=================================================================
USAGE:
=================================================================

Setelah login/register, user akan melihat:
- Logo GrowPlanner di tengah atas
- 3 tombol menu besar:
  1. Dashboard → ke Home screen dengan bottom nav
  2. TimeSync → ke kalender & jadwal
  3. ConflictDetails → ke deteksi konflik
- Tombol Keluar di bawah

User bisa langsung pilih fitur yang diinginkan tanpa harus
melalui bottom navigation dulu.
*/
