import 'package:dual_sim_info/ContactList.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Ensure MaterialApp is used at the root
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '',
          style: TextStyle(
              fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: SimDetailsWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Contactlist()),
          );
        },
        child: Icon(Icons.contact_phone,color: Colors.blueGrey,),
      ),
    );
  }
}

class SimDetailsWidget extends StatefulWidget {
  @override
  _SimDetailsWidgetState createState() => _SimDetailsWidgetState();
}

class _SimDetailsWidgetState extends State<SimDetailsWidget> {
  List<Map<String, String>> _simDetails = [];

  @override
  void initState() {
    super.initState();
    _fetchSimDetails();
  }

  Future<void> _fetchSimDetails() async {
    final simDetails = await SimDetails().getSimDetails();
    setState(() {
      _simDetails = simDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _simDetails.length,
      itemBuilder: (context, index) {
        final simDetail = _simDetails[index];
        return Card(
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SIM ${index + 1}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Carrier: ${simDetail["carrierName"]}',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Number: ${simDetail["number"]}',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SimDetails {
  static const platform = MethodChannel('com.example.dual_sim_info/sim_details');

  Future<List<Map<String, String>>> getSimDetails() async {
    try {
      final List<dynamic> result = await platform.invokeMethod('getSimDetails');
      print("Result from native: $result");
      return result.map((e) => Map<String, String>.from(e)).toList();
    } on PlatformException catch (e) {
      print("Failed to get SIM details: '${e.message}'.");
      return [];
    }
  }
}
