import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_with_hive/core/global.dart';
import 'package:flutter_with_hive/core/utils/api_urls.dart';
import 'package:flutter_with_hive/core/utils/print_log.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

// Message Model
class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({required this.text, required this.isUser, required this.timestamp});
}

// Chat Controller
class AiChatBotController extends GetxController {
  static AiChatBotController get to => Get.find();
  final messages = <Message>[].obs;
  final isTyping = false.obs;
  final isListening = false.obs;
  final textController = TextEditingController();
  static const String _geminiUrl = '${ApiUrls.geminiUrlFPoint}$geminiModel:generateContent';

  /// 🌐 Internet connection observable
  RxBool isOnline = false.obs;

  /// Connectivity subscription
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Input controller owned by the GetX controller so the widget does not
  // have to manage a local TextEditingController. voiceText changes are
  // mirrored into this controller so interim STT results appear live.
  // final TextEditingController inputController = TextEditingController();
  final voiceText = ''.obs;

  // Speech
  late stt.SpeechToText _speechToText;

  // Keys / config - loaded from .env file for security
  String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  String assistantId = 'd01cf2c7-6f67-4a6c-872e-571a5193c009';

  @override
  void onInit() {
    super.onInit();
    messages.add(Message(text: "Hi! I'm your AI assistant 🤖. How can I help you today?", isUser: false, timestamp: DateTime.now()));
    // Start connectivity monitoring
    _initConnectivity();
    _speechToText = stt.SpeechToText();
    _initSpeech();
    // Mirror voiceText into the input field so the UI shows interim results
    // without the widget needing to bind a controller.
    ever(voiceText, (String v) {
      if (textController.text != v) {
        textController.text = v;
        textController.selection = TextSelection.fromPosition(TextPosition(offset: textController.text.length));
      }
    });
  }

  Future<void> _initSpeech() async {
    await _speechToText.initialize();
  }

  Future<void> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw Exception('Microphone permission not granted');
    }
  }

  //////////////////////////  for listening  /////////////////////////////
  /// Start listening immediately. Intended for press-and-hold UX.
  Future<void> startListening() async {
    if (isListening.value) return;

    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      await requestMicrophonePermission();
      return;
    }

    final available = await _speechToText.initialize();
    if (!available) throw Exception('Speech recognition not available');

    isListening.value = true;
    voiceText.value = '';
    _speechToText.listen(
      onResult: (result) {
        voiceText.value = result.recognizedWords;
      },
      // Set a long listen duration; we'll stop explicitly on button release.
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: stt.ListenMode.dictation,
    );
  }

  /// Stop listening (used on button release) and send the captured text.
  Future<void> stopListeningAndSend() async {
    if (!isListening.value) return;
    await _speechToText.stop();
    isListening.value = false;
    final text = voiceText.value.trim();
    if (text.isNotEmpty) {
      await sendMessage(text);
      voiceText.value = '';
    }
  }

  /// Toggle kept for backwards compatibility with existing UI that used tap to toggle.
  Future<void> toggleListening() async {
    if (isListening.value) {
      await stopListeningAndSend();
    } else {
      await startListening();
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////  check online conection
  ///  Initialize and listen to connectivity changes
  Future<void> _initConnectivity() async {
    // Check initial connection
    final initialResult = await Connectivity().checkConnectivity();
    isOnline.value = !_isDisconnected(initialResult);

    // Listen to connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      final onlineNow = !_isDisconnected(result);
      isOnline.value = onlineNow;
    });
  }

  /// Current connectivity type (wifi, mobile, ethernet, none, etc.)
  Rx<ConnectivityResult> connectionType = ConnectivityResult.none.obs;

  /// Human-friendly label for the current connection type
  String get connectionTypeLabel {
    switch (connectionType.value) {
      case ConnectivityResult.wifi:
        return 'Wi‑Fi';
      case ConnectivityResult.mobile:
        return 'Mobile';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'None';
    }
  }

  /// Helper: Checks if the connection list means offline
  bool _isDisconnected(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.none);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////// end connection

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    messages.add(Message(text: text, isUser: true, timestamp: DateTime.now()));
    textController.clear();
    // Show typing
    isTyping.value = true;
    // Get response from Gemini
    final responseText = await _callGemini(text);

    isTyping.value = false;

    // Add bot response
    messages.add(Message(text: responseText ?? "⚠️ Sorry, I couldn't get a response right now.", isUser: false, timestamp: DateTime.now()));
  }

  // /// ✅ Correct Gemini API call
  // Future<String?> _callGemini(String prompt) async {
  //   if (geminiApiKey.isEmpty) {
  //     printLog("❌ Gemini API key missing");
  //     return null;
  //   }

  //   try {
  //     final uri = Uri.parse('$_geminiUrl?key=$geminiApiKey');
  //     final client = HttpClient();
  //     final request = await client.postUrl(uri);
  //     request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');

  //     final body = jsonEncode({
  //       "contents": [
  //         {
  //           "parts": [
  //             {"text": prompt},
  //           ],
  //         },
  //       ],
  //     });

  //     request.add(utf8.encode(body));
  //     final response = await request.close();
  //     final respBody = await response.transform(utf8.decoder).join();
  //     client.close();

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final decoded = jsonDecode(respBody);
  //       final text = decoded["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];
  //       return text ?? "No response text found.";
  //     } else {
  //       printLog("❌ Gemini API error: ${response.statusCode} - $respBody");
  //       return "Error ${response.statusCode}: Unable to fetch response.";
  //     }
  //   } catch (e) {
  //     printLog("⚠️ Exception during Gemini API call: $e");
  //     return null;
  //   }
  // }
  /// ✅ Gemini API call with automatic retry on 503 or network errors
Future<String?> _callGemini(String prompt) async {
  if (geminiApiKey.isEmpty) {
    printLog("❌ Gemini API key missing");
    return null;
  }

  const int maxRetries = 3; // you can tune this (e.g., 5)
  const Duration retryDelay = Duration(seconds: 3);

  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      final uri = Uri.parse('$_geminiUrl?key=$geminiApiKey');
      final client = HttpClient();
      final request = await client.postUrl(uri);
      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'application/json; charset=utf-8',
      );

      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      });

      request.add(utf8.encode(body));
      final response = await request.close();
      final respBody = await response.transform(utf8.decoder).join();
      client.close();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(respBody);
        final text = decoded["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];
        return text ?? "No response text found.";
      } else if (response.statusCode == 503) {
        // 🕒 Model overloaded, wait & retry
        printLog("⚠️ Gemini overloaded (503). Retrying in ${retryDelay.inSeconds}s... [Attempt $attempt/$maxRetries]");
        if (attempt < maxRetries) {
          await Future.delayed(retryDelay);
          continue;
        } else {
          return "Gemini servers are busy. Please try again later.";
        }
      } else {
        printLog("❌ Gemini API error: ${response.statusCode} - $respBody");
        return "Error ${response.statusCode}: Unable to fetch response.";
      }
    } catch (e) {
      // Handle transient network issues
      printLog("⚠️ Exception during Gemini API call (attempt $attempt): $e");
      if (attempt < maxRetries) {
        printLog("🔁 Retrying in ${retryDelay.inSeconds}s...");
        await Future.delayed(retryDelay);
        continue;
      } else {
        return "Network error. Please try again later.";
      }
    }
  }

  // Just in case all attempts fail
  return "Failed to get response after multiple attempts.";
}


  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    textController.dispose();
    _speechToText.stop();
    super.onClose();
  }
}
