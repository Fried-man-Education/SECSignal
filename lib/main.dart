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
  List<Map<String, String>> fakeFavorites = [
    {
      "name" : "Apple",
      "logo" : "https://static.vecteezy.com/system/resources/previews/000/249/015/non_2x/vector-modern-watercolor-colorful-headers-set-template-design.jpg",
      "description" : "Tech giant known for iPhones, Macs, and a sleek ecosystem. A favorite for many seeking both functionality and style."
    },
    {
      "name" : "Mike-Is-Soft",
      "logo" : "https://static.vecteezy.com/system/resources/previews/000/249/015/non_2x/vector-modern-watercolor-colorful-headers-set-template-design.jpg",
      "description" : "Software behemoth behind Windows, Office, and Azure. Continuously innovating and expanding its tech footprint."
    },
    {
      "name" : "Sony",
      "logo" : "https://static.vecteezy.com/system/resources/previews/000/249/015/non_2x/vector-modern-watercolor-colorful-headers-set-template-design.jpg",
      "description" : "Multinational conglomerate known for PlayStation, cameras, and entertainment. A leader in both tech and content."
    },
    {
      "name" : "Netflix",
      "logo" : "https://static.vecteezy.com/system/resources/previews/000/249/015/non_2x/vector-modern-watercolor-colorful-headers-set-template-design.jpg",
      "description" : "Streaming powerhouse with a vast library of shows and movies. Home to many binge-worthy series."
    },
    {
      "name" : "Tesla",
      "logo" : "https://static.vecteezy.com/system/resources/previews/000/249/015/non_2x/vector-modern-watercolor-colorful-headers-set-template-design.jpg",
      "description" : "Electric car and clean energy innovator. Pushing the boundaries of transportation and sustainability."
    },
    {
      "name" : "TikTok",
      "logo" : "https://static.vecteezy.com/system/resources/previews/000/249/015/non_2x/vector-modern-watercolor-colorful-headers-set-template-design.jpg",
      "description" : "Social media app focused on short, catchy videos. A cultural phenomenon among the younger generation."
    },
    {
      "name" : "Spotify",
      "logo" : "https://static.vecteezy.com/system/resources/previews/000/249/015/non_2x/vector-modern-watercolor-colorful-headers-set-template-design.jpg",
      "description" : "Music streaming service with millions of songs and playlists. Tailored listening experiences for every mood."
    }
  ];

  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: PlatformTextField(
                    cupertino: (BuildContext context, PlatformTarget platformTarget) => CupertinoTextFieldData(
                      placeholder: "Search by Name, CIK, or Ticker",
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                      ),
                      prefix: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          CupertinoIcons.search,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    material: (BuildContext context, PlatformTarget platformTarget) => MaterialTextFieldData(
                      decoration: InputDecoration(
                        hintText: "Search by Name, CIK, or Ticker",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        isDense: true,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    onChanged: (value) {},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: 20.0,
                    ),
                  ),
                )
              ],
            ),
            for (int i = 0; i < 2; i++) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  i == 0 ? "Favorites" : "Hot",
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 300,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    _controller.jumpTo(_controller.offset - details.delta.dx);
                  },
                  child: ListView(
                    controller: _controller,
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (Map<String, String> company in fakeFavorites)
                        SizedBox(
                          width: 300,
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  company["name"]!,
                                  style: const TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  company["description"]!,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Expanded(
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Image.network(
                                      company["logo"]!,
                                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return Center(
                                            child: PlatformCircularProgressIndicator(),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
