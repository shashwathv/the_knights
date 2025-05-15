import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:html' as html;
import '../services/language_provider.dart';
import '../services/khetsetu_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final KhetSetuService _khetSetuService = KhetSetuService();
  bool _isListening = false;
  bool _isLoading = true;
  String _lastWords = '';
  String _response = '';
  String _error = '';
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _requestMicrophonePermission() async {
    try {
      final html.MediaStream stream = await html.window.navigator.mediaDevices?.getUserMedia({'audio': true}) ?? 
          (throw Exception('MediaDevices not available'));
      stream.getTracks().forEach((track) => track.stop());
      print('Microphone permission granted');
      setState(() => _hasPermission = true);
      return;
    } catch (e) {
      print('Error requesting microphone permission: $e');
      setState(() => _hasPermission = false);
      throw Exception('Microphone permission denied');
    }
  }

  Future<void> _initializeServices() async {
    try {
      print('Initializing speech recognition...');
      bool speechInitialized = await _speechToText.initialize(
        onError: (error) {
          print('Speech recognition error: $error');
          setState(() {
            if (error.errorMsg == 'no-speech') {
              _error = 'No speech detected. Please try speaking again.';
            } else {
              _error = 'Error: ${error.errorMsg}';
            }
            if (error.permanent) {
              _isListening = false;
            }
          });
        },
        onStatus: (status) {
          print('Speech status: $status');
          if (status == 'notListening' || status == 'done') {
            setState(() => _isListening = false);
          }
        },
        debugLogging: true,
      );
      print('Speech recognition initialized: $speechInitialized');

      print('Initializing TTS...');
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      print('TTS initialized');

      print('Initializing KhetSetu service...');
      await _khetSetuService.initialize();
      print('KhetSetu service initialized');

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (!speechInitialized) {
            _error = 'Could not initialize speech recognition';
          }
        });
      }
    } catch (e) {
      print('Initialization error: $e');
      if (mounted) {
        setState(() {
          _error = 'Error initializing: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startListening() async {
    try {
      if (!_hasPermission) {
        await _requestMicrophonePermission();
      }

      setState(() {
        _error = '';
        _lastWords = '';
        _response = '';
      });

      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      final locale = languageProvider.isEnglish ? 'en-US' : 'kn-IN';
      print('Starting speech recognition in $locale...');

      if (!await _speechToText.hasPermission) {
        throw Exception('Speech recognition permission not granted');
      }

      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: locale,
        listenFor: const Duration(seconds: 30),
        partialResults: true,
        onSoundLevelChange: (level) => print('Sound level: $level'),
        cancelOnError: true,
      );

      setState(() => _isListening = true);
    } catch (e) {
      print('Error starting speech recognition: $e');
      setState(() {
        _error = 'Could not start listening: $e';
        _isListening = false;
      });
    }
  }

  Future<void> _stopListening() async {
    print('Stopping speech recognition...');
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    print('Speech result: ${result.recognizedWords} (${result.finalResult ? 'final' : 'partial'})');
    setState(() {
      _lastWords = result.recognizedWords;
      if (result.finalResult) {
        _processVoiceCommand(_lastWords);
      }
    });
  }

  Future<void> _processVoiceCommand(String command) async {
    print('Processing command: $command');
    try {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      final response = await _khetSetuService.processQuery(
        command,
        languageProvider.isEnglish ? 'en' : 'kn',
      );
      setState(() => _response = response);
      await _speak(response);
    } catch (e) {
      print('Error processing command: $e');
      setState(() => _error = 'Error processing command: $e');
    }
  }

  Future<void> _speak(String text) async {
    print('Speaking response: $text');
    try {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      await _flutterTts.setLanguage(languageProvider.isEnglish ? 'en-US' : 'kn-IN');
      await _flutterTts.speak(text);
    } catch (e) {
      print('Error speaking: $e');
      setState(() => _error = 'Error speaking: $e');
    }
  }

  Widget _buildInstructions(BuildContext context, bool isEnglish) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEnglish ? 'Try asking about:' : 'ಇವುಗಳ ಬಗ್ಗೆ ಕೇಳಿ:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(isEnglish
                ? '• Crop information (e.g., "Tell me about paddy")\n'
                  '• Loan details (e.g., "What is the loan amount for wheat?")\n'
                  '• Cultivation guide (e.g., "How to grow maize?")\n'
                  '• Available subsidies (e.g., "Show me subsidies")\n'
                  '• Loan providers (e.g., "Show me lenders")'
                : '• ಬೆಳೆ ಮಾಹಿತಿ (ಉದಾ: "ಭತ್ತದ ಬಗ್ಗೆ ಹೇಳಿ")\n'
                  '• ಸಾಲದ ವಿವರಗಳು (ಉದಾ: "ಗೋಧಿಗೆ ಸಾಲದ ಮೊತ್ತ ಎಷ್ಟು?")\n'
                  '• ಕೃಷಿ ಮಾರ್ಗದರ್ಶನ (ಉದಾ: "ಮೆಕ್ಕೆಜೋಳ ಹೇಗೆ ಬೆಳೆಯಬೇಕು?")\n'
                  '• ಲಭ್ಯವಿರುವ ಸಬ್ಸಿಡಿಗಳು (ಉದಾ: "ಸಬ್ಸಿಡಿಗಳನ್ನು ತೋರಿಸಿ")\n'
                  '• ಸಾಲದಾತರು (ಉದಾ: "ಸಾಲದಾತರನ್ನು ತೋರಿಸಿ")',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KhetSetu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              return TextButton(
                onPressed: () {
                  languageProvider.setLanguage(
                    languageProvider.isEnglish ? 'kn' : 'en',
                  );
                },
                child: Text(
                  languageProvider.isEnglish ? 'ಕನ್ನಡ' : 'English',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.green.shade50,
                    Colors.white,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_error.isNotEmpty)
                          Card(
                            color: Colors.red.shade100,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _error,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Consumer<LanguageProvider>(
                          builder: (context, languageProvider, _) {
                            return _buildInstructions(context, languageProvider.isEnglish);
                          },
                        ),
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(
                                  _isListening ? Icons.mic : Icons.mic_none,
                                  size: 48,
                                  color: _isListening ? Colors.green : Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Consumer<LanguageProvider>(
                                  builder: (context, languageProvider, child) {
                                    return Text(
                                      _isListening
                                          ? (languageProvider.isEnglish
                                              ? 'Listening...'
                                              : 'ಆಲಿಸುತ್ತಿದೆ...')
                                          : (languageProvider.isEnglish
                                              ? 'Tap the microphone to start speaking'
                                              : 'ಮಾತನಾಡಲು ಮೈಕ್ರೋಫೋನ್ ಅನ್ನು ಟ್ಯಾಪ್ ಮಾಡಿ'),
                                      style: Theme.of(context).textTheme.titleLarge,
                                      textAlign: TextAlign.center,
                                    );
                                  },
                                ),
                                if (_isListening)
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: LinearProgressIndicator(),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (_lastWords.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Consumer<LanguageProvider>(
                                    builder: (context, languageProvider, child) {
                                      return Text(
                                        languageProvider.isEnglish
                                            ? 'You said:'
                                            : 'ನೀವು ಹೇಳಿದ್ದು:',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _lastWords,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (_response.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Card(
                            elevation: 2,
                            color: Colors.green.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Consumer<LanguageProvider>(
                                    builder: (context, languageProvider, child) {
                                      return Text(
                                        languageProvider.isEnglish
                                            ? 'Response:'
                                            : 'ಪ್ರತಿಕ್ರಿಯೆ:',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _response,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: _isListening ? _stopListening : _startListening,
        tooltip: 'Listen',
        child: Icon(_isListening ? Icons.mic_off : Icons.mic),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }
} 