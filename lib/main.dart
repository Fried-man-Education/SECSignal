import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:secsignal/pages/home.dart';

void main() {
  runApp(const SecSignal());
}

late Color borderColor;

class SecSignal extends StatefulWidget {
  const SecSignal({Key? key}) : super(key: key);

  @override
  State<SecSignal> createState() => _SecSignal();
}

class _SecSignal  extends State<SecSignal> with WidgetsBindingObserver {
  final brightnessNotifier = ValueNotifier(WidgetsBinding.instance.platformDispatcher.platformBrightness);
  Brightness brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
  late Color primaryColor;
  final TextTheme textTheme = const TextTheme(
    bodyMedium: TextStyle(fontFamily: 'IBM_Plex_Sans'), // Regular font
    bodyLarge: TextStyle(fontFamily: 'IBM_Plex_Sans', fontWeight: FontWeight.bold), // Bold font
    bodySmall: TextStyle(fontFamily: 'IBM_Plex_Sans', fontStyle: FontStyle.italic), // Italic font
    displayLarge: TextStyle(fontFamily: 'IBM_Plex_Sans'),
    displayMedium: TextStyle(fontFamily: 'IBM_Plex_Sans'),
    displaySmall: TextStyle(fontFamily: 'IBM_Plex_Sans'),
    headlineMedium: TextStyle(fontFamily: 'IBM_Plex_Sans'),
    headlineSmall: TextStyle(fontFamily: 'IBM_Plex_Sans'),
    titleLarge: TextStyle(fontFamily: 'IBM_Plex_Sans'),
    titleMedium: TextStyle(fontFamily: 'IBM_Plex_Sans'),
    titleSmall: TextStyle(fontFamily: 'IBM_Plex_Sans'),
    labelLarge: TextStyle(fontFamily: 'IBM_Plex_Sans'),
    labelSmall: TextStyle(fontFamily: 'IBM_Plex_Sans'),
  );

  late CupertinoTextThemeData cupertinoTextTheme;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    primaryColor = brightness == Brightness.light ? const Color(0xff345078) : lighten(const Color(0xff345078));

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
      navLargeTitleTextStyle: const TextStyle(
        fontFamily: 'IBM_Plex_Sans',
        fontWeight: FontWeight.bold,
        fontSize: 34,
      ),
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
          bool isLight = false; // brightness == Brightness.light

          primaryColor = isLight ? const Color(0xff345078) : lighten(const Color(0xff345078));
          borderColor = isLight ? Colors.black : Colors.white;

          return PlatformProvider(
            settings: PlatformSettingsData(
              iosUsesMaterialWidgets: true,
            ),
            builder: (context) => PlatformTheme(
              themeMode: isLight ? ThemeMode.light : ThemeMode.dark,
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
                      type: BottomNavigationBarType.fixed
                  ),
                  iconTheme: const IconThemeData(
                    color: Colors.black54,
                  )
              ),
              materialDarkTheme: ThemeData.dark().copyWith(
                primaryColor: primaryColor,
              ),
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
              builder: (context) => const PlatformApp(
                debugShowCheckedModeBanner: false,
                localizationsDelegates: <LocalizationsDelegate<dynamic>>[
                  DefaultMaterialLocalizations.delegate,
                  DefaultWidgetsLocalizations.delegate,
                  DefaultCupertinoLocalizations.delegate,
                ],
                title: 'SECSignal',
                home: Home(title: "SECSignal"),
              ),
            ),
          );
        }
    );
  }

  Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

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
