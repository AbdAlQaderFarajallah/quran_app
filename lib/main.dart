import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
        path: 'assets',
        fallbackLocale: const Locale('en', 'US'),
        child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'Quran App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPage = 1;
  late int searchPage ;
  bool isLoading = false;
  dynamic data;

  late TextEditingController controller;

  late PageController pageController;

  getData(int page) async {
    data = [];
    http.Response response = await http.get(
      Uri.parse('http://api.alquran.cloud/v1/page/$page/quran-uthmani'),
    );

    var result = jsonDecode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        isLoading = true;
        data = result['data']['ayahs'] as List;
      });
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    pageController = PageController(initialPage: 1);
    getData(currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE6C9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3EDC8),
        title: const Text('Quran' ,style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.search , color: Colors.black),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Enter the page number you want to go to"),
                  content: TextField(
                    controller: controller,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        searchPage = int.parse(controller.text) ;
                        getData(searchPage);
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Go',
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  ],
                );
              },
            );
          },
        ),
      ),
      // drawer: Drawer(),
      body: Center(
        child: !isLoading
            ? const CircularProgressIndicator()
            : SafeArea(
                child: PageView.builder(
                  itemCount: 604,
                  controller: pageController,
                  onPageChanged: (page) {
                    setState(() {
                      currentPage = page;
                      getData(page);
                    });
                  },
                  itemBuilder: (BuildContext context, int index) {
                    if (index == currentPage && data.length != 0) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: RichText(
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.center,
                            locale: context.locale,
                            text: TextSpan(
                                text: '',
                                recognizer: DoubleTapGestureRecognizer()
                                  ..onDoubleTap = () {
                                    setState(() {});
                                  },
                                style: const TextStyle(
                                  fontFamily: 'HafsSmart',
                                  color: Colors.black,
                                  fontSize: 19,
                                  textBaseline: TextBaseline.alphabetic,
                                ),
                                children: [
                                  for (int i = 0; i < data.length; i++) ...{
                                    TextSpan(
                                      text: '${data[i]['text']}',
                                    ),
                                    WidgetSpan(
                                      baseline: TextBaseline.alphabetic,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 6),
                                        decoration: BoxDecoration(
                                          image: const DecorationImage(
                                            opacity: 1,
                                            image: AssetImage(
                                              'images/end.png',
                                            ),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                            '${data[i]['numberInSurah']}'),
                                      ),
                                    ),
                                  }
                                ]),
                          ),
                        ),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
      ),
    );
  }
}
