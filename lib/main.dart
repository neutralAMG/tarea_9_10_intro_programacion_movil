import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter OpenStreetMap',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const InputScreen(),
    );
  }
}

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  void _goToMap() {
    if (_nameController.text.isEmpty ||
        _surnameController.text.isEmpty ||
        _latitudeController.text.isEmpty ||
        _longitudeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      return;
    }

    double? latitude = double.tryParse(_latitudeController.text);
    double? longitude = double.tryParse(_longitudeController.text);

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa coordenadas válidas.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MapScreen(
              name: _nameController.text,
              surname: _surnameController.text,
              latitude: latitude,
              longitude: longitude,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingresar Datos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _surnameController,
              decoration: const InputDecoration(labelText: 'Apellido'),
            ),
            TextField(
              controller: _latitudeController,
              decoration: const InputDecoration(labelText: 'Latitud'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _longitudeController,
              decoration: const InputDecoration(labelText: 'Longitud'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _goToMap, child: const Text('Siguiente')),
          ],
        ),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  final String name;
  final String surname;
  final double latitude;
  final double longitude;

  const MapScreen({
    super.key,
    required this.name,
    required this.surname,
    required this.latitude,
    required this.longitude,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String locationInfo = "Cargando...";

  @override
  void initState() {
    super.initState();
    _getLocationInfo();
  }

  Future<void> _getLocationInfo() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.latitude,
        widget.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          locationInfo = "${place.locality}, ${place.country}";
        });
      }
    } catch (e) {
      setState(() {
        locationInfo = "Ubicación no encontrada";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(widget.latitude, widget.longitude),
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(widget.latitude, widget.longitude),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text("${widget.name} ${widget.surname}"),
                            content: Text(locationInfo),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cerrar"),
                              ),
                            ],
                          ),
                    );
                  },
                  child: const Icon(
                    Icons.location_on,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
