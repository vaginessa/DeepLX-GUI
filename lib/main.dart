import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const TranslatorApp());
}

class TranslatorApp extends StatelessWidget {
  const TranslatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: MaterialColor(
            0xFF6200EE,
            <int, Color>{
              50: const Color.fromARGB(255, 231, 231, 246),
              100: const Color(0xFFD1C4E9),
              200: const Color(0xFFB39DDB),
              300: const Color(0xFF9575CD),
              400: const Color(0xFF7E57C2),
              500: const Color(0xFF6200EE),
              600: const Color(0xFF5E35B1),
              700: const Color(0xFF512DA8),
              800: const Color(0xFF4527A0),
              900: const Color(0xFF311B92),
            },
          ),
        ),
      ),
      home: const TranslatorScreen(),
    );
  }
}

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({Key? key}) : super(key: key);

  @override
  _TranslatorScreenState createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _sourceTextController = TextEditingController();
  final TextEditingController _targetTextController = TextEditingController();
  String _sourceLang = 'auto';
  String _targetLang = 'EN';
  Timer? _debounce;

  void _translate() async {
    final data = {
      "text": _sourceTextController.text,
      "source_lang": _sourceLang,
      "target_lang": _targetLang,
    };
    final response = await http.post(Uri.parse('http://127.0.0.1:1188/translate'),
        body: jsonEncode(data));
    if (response.body.isEmpty) {
      setState(() {
        _targetTextController.text = ""; // Если ответ пуст, используем пустую строку
      });
    } else {
      final responseJson = jsonDecode(response.body);
      setState(() {
        _targetTextController.text = responseJson["data"] ?? ""; // Если значение null, используем пустую строку
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translator'),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > 600) {
            return _buildWideLayout();
          } else {
            return _buildNarrowLayout();
          }
        },
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButton<String>(
                value: _sourceLang,
                onChanged: (String? newValue) {
                  setState(() {
                    _sourceLang = newValue!;
                  });
                },
                items: languagesWithAuto.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              TextField(
                controller: _sourceTextController,
                onChanged: (value) {
                  _scheduleTranslate();
                },
                maxLines: null, // Позволяет текстовому полю автоматически расширяться по вертикали
              ),
              ElevatedButton(
                onPressed: _translate,
                child: const Text('Translate'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButton<String>(
                value: _targetLang,
                onChanged: (String? newValue) {
                  setState(() {
                    _targetLang = newValue!;
                    _translate(); // Добавляем вызов функции перевода
                  });
                },
                items: languagesWithoutAuto.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              TextField(
                controller: _targetTextController,
                readOnly: true,
                maxLines: null, // Позволяет текстовому полю автоматически расширяться по вертикали
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButton<String>(
          value: _sourceLang,
          onChanged: (String? newValue) {
            setState(() {
              _sourceLang = newValue!;
            });
          },
          items: languagesWithAuto.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        TextField(
          controller: _sourceTextController,
          onChanged: (value) {
            _scheduleTranslate();
          },
          maxLines: null, // Позволяет текстовому полю автоматически расширяться по вертикали
        ),
        ElevatedButton(
          onPressed: _translate,
          child: const Text('Translate'),
        ),
        DropdownButton<String>(
          value: _targetLang,
          onChanged: (String? newValue) {
            setState(() {
              _targetLang = newValue!;
              _translate(); // Добавляем вызов функции перевода
            });
          },
          items: languagesWithoutAuto.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        TextField(
          controller: _targetTextController,
          readOnly: true,
          maxLines: null, // Позволяет текстовому полю автоматически расширяться по вертикали
        ),
      ],
    );
  }

  void _scheduleTranslate() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      _translate();
    });
  }

  List<String> languagesWithAuto = [
    'auto',
    'BG',
    'CS',
    'DA',
    'DE',
    'EL',
    'EN',
    'ES',
    'ET',
    'FI',
    'FR',
    'HU',
    'ID',
    'IT',
    'JA',
    'KO',
    'LT',
    'LV',
    'NB',
    'NL',
    'PL',
    'PT',
    'RO',
    'RU',
    'SK',
    'SL',
    'SV',
    'TR',
    'UK',
    'ZH',
  ];

  List<String> languagesWithoutAuto = [
    'BG',
    'CS',
    'DA',
    'DE',
    'EL',
    'EN',
    'ES',
    'ET',
    'FI',
    'FR',
    'HU',
    'ID',
    'IT',
    'JA',
    'KO',
    'LT',
    'LV',
    'NB',
    'NL',
    'PL',
    'PT',
    'RO',
    'RU',
    'SK',
    'SL',
    'SV',
    'TR',
    'UK',
    'ZH',
  ];
}
