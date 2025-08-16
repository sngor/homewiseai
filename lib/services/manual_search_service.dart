import 'package:http/http.dart' as http;
import 'dart:convert';

class ManualSearchService {
  Future<List<String>> searchManual({required String applianceName, String? modelNumber}) async {
    final query = Uri.encodeComponent('$applianceName ${modelNumber ?? ''} manual');
    // Using DuckDuckGo's search API for a basic example.
    // Note: Directly scraping search results can be unreliable and against terms of service.
    // A more robust solution might involve using a dedicated search API or a web scraping library.
    final url = Uri.parse('https://api.duckduckgo.com/?q=$query&format=json&pretty=1');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // This is a very basic attempt to extract URLs from the DuckDuckGo API response.
        // The structure of the response might change, and a more sophisticated parser
        // would be needed for reliable extraction in a real-world application.
        List<String> links = [];
        if (data['RelatedTopics'] != null) {
          for (var topic in data['RelatedTopics']) {
            if (topic['FirstURL'] != null) {
              links.add(topic['FirstURL']);
            }
          }
        }
        return links;
      } else {
        print('Search request failed with status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error during manual search: $e');
      return [];
    }
  }
}