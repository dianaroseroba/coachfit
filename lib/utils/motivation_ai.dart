import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String> getMotivationalMessage() async {
  final apiKey = dotenv.env['GEMINI_API_KEY']; // ✅ nombre de variable del .env

  if (apiKey == null || apiKey.isEmpty) {
    return '❗ Clave API no configurada.';
  }

  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  try {
    final prompt = "Dame una frase motivacional corta para una persona que acaba de hacer ejercicio.";
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? "¡Sigue adelante! 💪";
  } catch (e) {
    return '❌ Error al generar frase IA.';
  }
}
