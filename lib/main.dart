import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: PetrolStationList(),
    ));

class PetrolStationList extends StatefulWidget {
  @override
  _PetrolStationListState createState() => _PetrolStationListState();
}

class _PetrolStationListState extends State<PetrolStationList> {
  List<List<dynamic>> _data = [];
  final String _csvUrl = "https://docs.google.com/spreadsheets/d/e/2PACX-1vToxrH-aGsZO1m6ObTPqfvXYDjNS9DiRCGDat4rW_5TnSCmXhF7tnlbMiBApYpIuxoGOqpbnj2FVKuS/pub?output=csv"; 

  Future<void> _fetchData() async {
    try {
      final response = await http.get(Uri.parse(_csvUrl));
      if (response.statusCode == 200) {
        setState(() => _data = const CsvToListConverter().convert(response.body));
      }
    } catch (e) { print("Fetch error: $e"); }
  }

  @override
  void initState() { super.initState(); _fetchData(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hyd Petrol Live ⛽", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData)],
      ),
      body: _data.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _data.length - 1,
              itemBuilder: (context, index) {
                final row = _data[index + 1];
                
                // Safety check: ensure row has all columns
                if (row.length < 6) return const SizedBox.shrink();

                String name = row[0].toString();
                String gMapsUrl = row[2].toString(); 
                String status = row[4].toString();
                String colorCode = row[5].toString().trim().toLowerCase();

                // FIXED: Added the '$' before the curly braces and '/search/' path
               String mapplsUrl = "https://mappls.com{Uri.encodeComponent(name)}?traffic=true";

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorCode == "red" ? Colors.red : Colors.green,
                          child: const Icon(Icons.local_gas_station, color: Colors.white),
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Status: $status"),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(
                            onPressed: () => html.window.open(gMapsUrl, "_blank"),
                            icon: const Icon(Icons.bar_chart),
                            label: const Text("Crowd Graph"),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => html.window.open(mapplsUrl, "_blank"),
                            icon: const Icon(Icons.traffic),
                            label: const Text("Road Traffic"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
