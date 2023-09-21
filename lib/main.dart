import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

void main() {
  runApp(SecSignal());
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
          primaryColor = brightness == Brightness.light ? const Color(0xff345078) : lighten(const Color(0xff345078));
          borderColor = brightness == Brightness.light ? Colors.black : Colors.white;

          return PlatformProvider(
            settings: PlatformSettingsData(
              iosUsesMaterialWidgets: true,
            ),
            builder: (context) => PlatformTheme(
              themeMode: brightness == Brightness.light ? ThemeMode.light : ThemeMode.dark,
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
              materialDarkTheme: ThemeData(
                primaryColor: primaryColor,
                canvasColor: const Color(0xFF121212),
                cardColor: const Color(0xFF222222),
                dialogBackgroundColor: const Color(0xFF272727),
                colorScheme: ColorScheme.fromSwatch(
                    primarySwatch: buildMaterialColor(primaryColor)
                ).copyWith(
                  secondary: primaryColor,
                  brightness: Brightness.dark,
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                        primary: buildMaterialColor(const Color(0xFF222222))
                    )
                ),
                buttonTheme: const ButtonThemeData(
                    buttonColor: Color(0xFF222222)
                ),
                iconTheme: IconThemeData(
                  color: Colors.white.withOpacity(.6),
                ),
                textTheme: textTheme,
                tabBarTheme: const TabBarTheme(
                  unselectedLabelColor: Colors.grey,
                ),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF121212),
                ),
                bottomNavigationBarTheme: BottomNavigationBarThemeData(
                    selectedItemColor: primaryColor,
                    unselectedItemColor: Colors.grey,
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                    type: BottomNavigationBarType.fixed
                ),
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

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<Home> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return PlatformScaffold(
      appBar: PlatformAppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).cardColor,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            //
            // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
            // action in the IDE, or press "p" in the console), to see the
            // wireframe for each widget.
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: _incrementCounter,
                  tooltip: 'Increment',
                  child: const Icon(Icons.add),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
