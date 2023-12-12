import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:secsignal/pages/home.dart';

import 'classes/user.dart';
import 'firebase_options.dart';

User? user;
UserDoc? userDoc;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  userDoc = await UserDoc.fromFirebase();

  runApp(const SecSignal());
}

late Color borderColor;

class SecSignal extends StatefulWidget {
  const SecSignal({Key? key}) : super(key: key);

  @override
  State<SecSignal> createState() => _SecSignal();
}

class _SecSignal extends State<SecSignal> with WidgetsBindingObserver {
  final brightnessNotifier = ValueNotifier(
      WidgetsBinding.instance.platformDispatcher.platformBrightness);
  Brightness brightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;
  late Color primaryColor;
  final TextTheme textTheme = TextTheme(
    bodyMedium: TextStyle(
        fontFamily: 'IBM_Plex_Sans',
        fontSize: 18,
        color: WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.light
            ? Colors.black
            : Colors.white),
    // Regular font
    bodyLarge: TextStyle(
        fontFamily: 'IBM_Plex_Sans',
        fontWeight: FontWeight.bold,
        color: WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.light
            ? Colors.black
            : Colors.white),
    // Bold font
    bodySmall: TextStyle(
        fontFamily: 'IBM_Plex_Sans',
        fontStyle: FontStyle.italic,
        color: WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.light
            ? Colors.black
            : Colors.white),
    // Italic font
    displayLarge: const TextStyle(fontFamily: 'IBM_Plex_Sans'),
    displayMedium: const TextStyle(fontFamily: 'IBM_Plex_Sans'),
    displaySmall: const TextStyle(fontFamily: 'IBM_Plex_Sans'),
    headlineMedium: const TextStyle(
        fontFamily: 'IBM_Plex_Sans', color: Colors.grey, fontSize: 18),
    headlineSmall: const TextStyle(fontFamily: 'IBM_Plex_Sans'),
    titleLarge: TextStyle(
        fontFamily: 'IBM_Plex_Sans',
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.light
            ? Colors.black
            : Colors.white),
    titleMedium: const TextStyle(fontFamily: 'IBM_Plex_Sans'),
    titleSmall: const TextStyle(fontFamily: 'IBM_Plex_Sans'),
    labelLarge: const TextStyle(fontFamily: 'IBM_Plex_Sans'),
    labelSmall: const TextStyle(fontFamily: 'IBM_Plex_Sans'),
  );

  late CupertinoTextThemeData cupertinoTextTheme;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    primaryColor = brightness == Brightness.light
        ? const Color(0xff345078)
        : lighten(const Color(0xff345078));

    cupertinoTextTheme = CupertinoTextThemeData(
      primaryColor: primaryColor,
      textStyle: textTheme.bodyMedium,
      actionTextStyle: textTheme.bodyLarge,
      tabLabelTextStyle: const TextStyle(
        fontFamily: 'IBM_Plex_Sans',
      ),
      navTitleTextStyle: const TextStyle(
        fontFamily: 'IBM_Plex_Sans',
        fontWeight: FontWeight.normal,
      ),
      navLargeTitleTextStyle: textTheme.titleLarge,
      navActionTextStyle: textTheme.bodyLarge,
      pickerTextStyle: const TextStyle(
        fontFamily: 'IBM_Plex_Sans',
        fontWeight: FontWeight.normal,
      ),
      dateTimePickerTextStyle: const TextStyle(
        fontFamily: 'IBM_Plex_Sans',
        fontWeight: FontWeight.normal,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    brightnessNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    brightnessNotifier.value = brightness;
    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: brightnessNotifier,
        builder: (context, Brightness brightness, child) {
          bool isLight = brightness == Brightness.light;

          primaryColor = isLight
              ? const Color(0xff345078)
              : lighten(const Color(0xff345078));
          borderColor = isLight ? Colors.black : Colors.white;

          return PlatformProvider(
            initialPlatform: TargetPlatform.iOS,
            settings: PlatformSettingsData(
              iosUsesMaterialWidgets: true,
            ),
            builder: (context) => PlatformTheme(
              themeMode: ThemeMode.dark,
              // isLight ? ThemeMode.light : ThemeMode.dark
              materialLightTheme: ThemeData(
                  primarySwatch: buildMaterialColor(primaryColor),
                  textTheme: textTheme,
                  tabBarTheme: const TabBarTheme(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                  ),
                  bottomNavigationBarTheme: BottomNavigationBarThemeData(
                      selectedItemColor: primaryColor,
                      unselectedItemColor: Colors.grey,
                      showSelectedLabels: true,
                      showUnselectedLabels: true,
                      type: BottomNavigationBarType.fixed),
                  iconTheme: const IconThemeData(
                    color: Colors.black54,
                  )),
              materialDarkTheme: ThemeData.dark()
                  .copyWith(primaryColor: primaryColor, textTheme: textTheme),
              cupertinoLightTheme: CupertinoThemeData(
                brightness: Brightness.light,
                primaryColor: primaryColor,
                textTheme: cupertinoTextTheme.copyWith(
                  primaryColor: Colors.white.withOpacity(.6),
                ),
              ),
              cupertinoDarkTheme: CupertinoThemeData(
                brightness: Brightness.dark,
                primaryColor: primaryColor,
                barBackgroundColor: const Color(0xFF121212),
                scaffoldBackgroundColor: const Color(0xFF121212),
                textTheme: cupertinoTextTheme,
              ),
              builder: (context) => PlatformApp(
                debugShowCheckedModeBanner: false,
                localizationsDelegates: <LocalizationsDelegate<dynamic>>[
                  DefaultMaterialLocalizations.delegate,
                  DefaultWidgetsLocalizations.delegate,
                  DefaultCupertinoLocalizations.delegate,
                ],
                title: 'SECSignal',
                home: (defaultTargetPlatform == TargetPlatform.iOS && kIsWeb) ||
                        (defaultTargetPlatform == TargetPlatform.android &&
                            kIsWeb)
                    ? const Illegal()
                    : const Home(),
              ),
            ),
          );
        });
  }

  Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  MaterialColor buildMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

// Function to convert a string to Title Case
String toTitleCase(String text) {
  if (text.isEmpty) return '';

  List<String> words = text.split(' ');
  return words.map((word) {
    if (word.isNotEmpty) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }
    return '';
  }).join(' ');
}

String formatDate(DateTime date) {
  String output = "";
  Duration diff = DateTime.now().difference(date);
  if (diff.inHours < 13) {
    if (diff.inHours < 1) {
      if (diff.inMinutes < 1) {
        if (diff.inSeconds < 10) {
          return "Now";
        }
        output += "${diff.inSeconds} seconds ago";
      } else if (diff.inMinutes == 1) {
        output += "${diff.inMinutes} minute ago";
      } else {
        output += "${diff.inMinutes} minutes ago";
      }
    } else if (diff.inHours == 1) {
      output += "${diff.inHours} hour ago";
    } else {
      output += "${diff.inHours} hours ago";
    }
  } else {
    if (diff.inDays == 0 && date.day == DateTime.now().day) {
      output += "Today";
    } else if (diff.inDays < 7) {
      output += DateFormat('EEEE').format(date);
    } else if (date.year == DateTime.now().year) {
      output += "${DateFormat.MMMM().format(date)} ${date.day}";
    } else {
      output += "${date.month}/${date.day}/${date.year}";
    }
    output += " ";
    if (date.hour == 0) {
      output += "12";
    } else {
      output +=
          (date.hour > 12) ? (date.hour - 12).toString() : date.hour.toString();
    }
    output += ":${date.minute.toString().padLeft(2, '0')} ";
    output += (date.hour > 12) ? "PM " : "AM ";
  }
  return output;
}

class Illegal extends StatelessWidget {
  const Illegal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
            child: SizedBox(
                height: min(MediaQuery.of(context).size.height / 2,
                    MediaQuery.of(context).size.width / 2),
                width: min(MediaQuery.of(context).size.height / 2,
                    MediaQuery.of(context).size.width / 2),
                child: Image.asset("error.gif"))),
        const Text(
          "Please view on desktop.",
          style: TextStyle(color: Colors.grey, fontSize: 20),
        ),
      ],
    ));
  }
}
