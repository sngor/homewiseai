import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'models/appliance.dart';
import 'screens/appliance_detail_screen.dart';


import 'dart:io';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  } // Removed the floating action button as it's not needed for this functionality
}
 class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}class _MyHomePageState extends State<MyHomePage> {
  final List<Appliance> _appliances = [];


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title. 
        title: Text(widget.title),
      ),
      body: _appliances.isEmpty
          ? const Center(
              child: Text('No appliances added yet.'),
            )
          : ListView.builder(
          itemCount: _appliances.length,
          itemBuilder: (context, index) {
            final appliance = _appliances[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              elevation: 2.0,
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ApplianceDetailScreen(appliance: appliance)),
                  );
                },
                title: Text(appliance.name ?? 'Unnamed Appliance'),
                subtitle: appliance.type != null
                    ? Text('${appliance.type} - ${appliance.modelNumber ?? ''}')
                    : Text(appliance.modelNumber ?? ''),
              ),
            );
          },
      ), // Changed the return type to Scaffold
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newAppliance = await Navigator.push<Appliance>(
            context,
            MaterialPageRoute(builder: (context) => const AddApplianceScreen()),
          );
          if (newAppliance != null) {
            setState(() {
              _appliances.add(newAppliance);
            });
          }
        },
        tooltip: 'Add Appliance',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddApplianceScreen extends StatefulWidget {
  const AddApplianceScreen({super.key});

  @override
  _AddApplianceScreenState createState() => _AddApplianceScreenState();
}

class _AddApplianceScreenState extends State<AddApplianceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _modelNumberController = TextEditingController();
  final _serialNumberController = TextEditingController();
  String _extractedText = '';

  Future<void> _pickImageAndExtractText() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final inputImage = InputImage.fromFile(File(pickedFile.path));
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      setState(() {
        _extractedText = recognizedText.text;
      });
    }
  }

  void _saveAppliance() {
    if (_formKey.currentState!.validate()) {
      final newAppliance = Appliance(
        name: _nameController.text.isEmpty ? null : _nameController.text,
        type: _typeController.text.isEmpty ? null : _typeController.text,
        modelNumber: _modelNumberController.text.isEmpty ? null : _modelNumberController.text,
        serialNumber: _serialNumberController.text.isEmpty ? null : _serialNumberController.text,
        purchaseDate: null, // You can add a date picker later
        maintenanceHistory: [], // Initialize with an empty list
        extractedLabelText: _extractedText.isEmpty ? null : _extractedText,
      );
      Navigator.pop(context, newAppliance);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _modelNumberController.dispose();
    _serialNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Appliance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Appliance Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an appliance name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              TextFormField(
                controller: _modelNumberController,
                decoration: const InputDecoration(labelText: 'Model Number'),
              ),
              TextFormField(
                controller: _serialNumberController,
                decoration: const InputDecoration(labelText: 'Serial Number'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImageAndExtractText,
                child: const Text('Pick Image and Extract Text'),
              ),
              const SizedBox(height: 20),
              if (_extractedText.isNotEmpty)
                Card(
                  elevation: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Extracted Text:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Text(_extractedText),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveAppliance,
                child: const Text('Save Appliance'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
