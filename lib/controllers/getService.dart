import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "https://sosmed-downloader-api.vercel.app/api/tiktok";

  static Future<Map<String, dynamic>?> fetchTikTokData(
    String url,
    String version,
  ) async {
    String apiUrl = "$baseUrl/$version";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"url": url}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        switch (version) {
          case "v1":
            return _parseV1Response(data);
          case "v2":
            return _parseV2Response(data);
          default:
            return {"error": "Unsupported API version"};
        }
      } else {
        return {
          "error": "Failed to fetch data. Status Code: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {"error": "Exception: $e"};
    }
  }

  static Map<String, dynamic> _parseV1Response(Map<String, dynamic> data) {
    try {
      return {
        "account": data["data"]["account_info"] ?? {},
        "media": data["data"]["mediaDownloader"] ?? {},
      };
    } catch (e) {
      return {"error": "Error parsing v1 response"};
    }
  }

  static Map<String, dynamic> _parseV2Response(Map<String, dynamic> data) {
    try {
      return {
        "account": {
          "nickname": data["data"]["creatorUsername"] ?? "Unknown",
          "profileImg": data["data"]["creatorProfile"] ?? "",
        },
        "media": {
          "videoDescription": data["data"]["videoDescription"] ?? "",
          "videoNoWatermark": data["data"]["videoNoWatermark"] ?? "",
          "videoMusic": data["data"]["videoMusic"] ?? "",
        },
      };
    } catch (e) {
      return {"error": "Error parsing v2 response"};
    }
  }
}
