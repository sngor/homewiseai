import 'package:flutter/material.dart';
import '../models/appliance.dart';
import '../services/manual_search_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplianceDetailScreen extends StatefulWidget {
  final Appliance appliance;

  const ApplianceDetailScreen({Key? key, required this.appliance}) : super(key: key);

  @override
  _ApplianceDetailScreenState createState() => _ApplianceDetailScreenState();
}

class _ApplianceDetailScreenState extends State<ApplianceDetailScreen> {
  bool _isLoadingManuals = false;
  List<String> _manualLinks = [];
  final ManualSearchService _searchService = ManualSearchService();

  void _searchManuals() async {
    setState(() {
      _isLoadingManuals = true;
    });
    _manualLinks = await _searchService.searchManual(widget.appliance.name ?? '', widget.appliance.modelNumber ?? '');
    setState(() {
      _isLoadingManuals = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appliance.name ?? 'Appliance Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Name: ${widget.appliance.name ?? "N/A"}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Model Number: ${widget.appliance.modelNumber ?? "N/A"}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Serial Number: ${widget.appliance.serialNumber ?? "N/A"}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Extracted Label Text:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              widget.appliance.extractedLabelText ?? "No label text extracted.",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoadingManuals ? null : _searchManuals,
              child: _isLoadingManuals
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text('Search for Manual'),
            ),
            SizedBox(height: 16),
            if (_manualLinks.isNotEmpty)
              Text('Potential Manuals:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (_manualLinks.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _manualLinks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_manualLinks[index]),
                    onTap: () async {
                      final url = Uri.parse(_manualLinks[index]);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                  );
                },
              )
              )
          ],
        ),
      ),
    );
  }
}