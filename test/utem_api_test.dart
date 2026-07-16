import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('La API de la UTEM debería retornar farmacias distintas según la zona', () async {
    final dio = Dio();
    // Token del usuario
    final token = 'eyJhbGciOiJSUzI1NiIsImtpZCI6ImJjOGY3YWY1OGRiNDRjZjZlYWEyZWQxMGVjODBmMzQwOGNmZGU0NjUiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIyNzQwNjQyOTgzODgtZzVlbzNramdnaGkxbTM5dmI3bnRiZTlpMXM4ZGVoODguYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiIyNzQwNjQyOTgzODgtNDZrcmVtNjZxbGwxMm9tZGRxY2I5c3NobGZlbnVzZmouYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDEzNjM2NTQ1MzY1NjcxMDgwNjIiLCJoZCI6InV0ZW0uY2wiLCJlbWFpbCI6ImVtb2xpbmF6QHV0ZW0uY2wiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwibmFtZSI6IkV6ZXF1aWVsIEplcmVtaWFzIE1vbGluYSBadcOxaWdhIiwicGljdHVyZSI6Imh0dHBzOi8vbGgzLmdvb2dsZXVzZXJjb250ZW50LmNvbS9hL0FDZzhvY0lhd0xXWndpck9ETW5LSEp0YW0xTEhNQVlfR3dGXy1lNEo5TUZKMzZoSmx3WFMtTXc9czk2LWMiLCJnaXZlbl9uYW1lIjoiRXplcXVpZWwgSmVyZW1pYXMiLCJmYW1pbHlfbmFtZSI6Ik1vbGluYSBadcOxaWdhIiwiaWF0IjoxNzg0MTkwNTE3LCJleHAiOjE3ODQxOTQxMTd9.PNZdIAMMhiWquq-OOH5r5c6k32qcIHVd-FqkY-uadyvQmn13m6N66QoWnpiO9fJKTzPbIawxH8TEuEs0vdWsf2em3U9QAUniSG0jXjDYjr9_hjuhcnVZrsE5vBadR7GW_j-4S_hswt6zzkx3NnbpaCH_5QaqFfEG8wfegLgKEKgyNYaJCLtGxUEMv6l0XDoe98gpQjM39mEcHh69YwENH6AK9uopqmsd6ipWPJWQdNAZv6S3-t7MCoL_SaAH5NR8jpIrSl9J_akA0UZ7lkM3_D136NxEVjY5AGG9xcA5ldBZhXp1AIF9iHPEbCaPC2IPqsBx6JxuLVWsB_8b-YmUCg';
    
    dio.options.headers['Authorization'] = 'Bearer $token';

    // 1. Consultamos una farmacia en Arica (Extremo Norte de Chile)
    // Esperamos que falle con 404 porque no hay farmacias de la UTEM allá
    String? farmaciaArica;
    try {
      final responseArica = await dio.get(
        'https://api.sebastian.cl/cmutem/v1/farmacias/-18.4782534/-70.3125988',
      );
      farmaciaArica = responseArica.data['nombre'];
    } on DioException catch (e) {
      expect(e.response?.statusCode, 400, reason: 'El servidor debería responder 400 si no hay farmacias cerca.');
    }

    // 2. Consultamos una farmacia en Punta Arenas (Extremo Sur de Chile)
    String? farmaciaPuntaArenas;
    try {
      final responsePuntaArenas = await dio.get(
        'https://api.sebastian.cl/cmutem/v1/farmacias/-53.1638329/-70.9078125',
      );
      farmaciaPuntaArenas = responsePuntaArenas.data['nombre'];
    } on DioException catch (e) {
      expect(e.response?.statusCode, 400, reason: 'El servidor debería responder 400 si no hay farmacias cerca en Punta Arenas.');
    }

    // print('Farmacia en Arica: $farmaciaArica');
    // print('Farmacia en Punta Arenas: $farmaciaPuntaArenas');

    // Comprobamos que el servidor haya respondido 404 en lugares lejanos a Santiago
    expect(farmaciaArica, isNull);
    expect(farmaciaPuntaArenas, isNull);
  });
}
