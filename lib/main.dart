import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'keys.dart';
import 'model/island_loc.dart';
import 'screens/newEntry.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Map with Points',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'My Map with Points'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  initState() {
    super.initState();
    getMyData();
  }

  getMyData() async {
    final response = await http.get(myAPIurl + "MyDataAPI", headers: {
      'authorization':
          "Basic " + base64Encode(utf8.encode(myAPIBasicAuthentication)),
      'Accept-Encoding': 'gzip'
    });
    List mapPoints = [];
    if (response.statusCode == 200 && response.body != null) {
      mapPoints = json.decode(utf8.decode(response.bodyBytes));
      fillMarkers(mapPoints);
    } else {
      _markers = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[dropIslandMenu()],
      ),
      body: getMap(),
      floatingActionButton: registerNewEntry(),
    );
  }

  Widget registerNewEntry() {
    if (newMarker == null) {
      return setNewEntryButton();
    } else {
      return submitNewEntryButton();
    }
  }

  FloatingActionButton setNewEntryButton() {
    return FloatingActionButton(
      backgroundColor: Colors.redAccent,
      child: Icon(
        Icons.edit_location,
        size: 40,
        color: Colors.white,
      ),
      onPressed: () {
        setNewMarker(mapController.center);
        setState(() {});
      },
    );
  }

  FloatingActionButton submitNewEntryButton() {
    return FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: Icon(
          Icons.check,
          size: 40,
          color: Colors.white,
        ),
        onPressed: () async {
          List result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return NewEntry(
                newPoint: newMarker.point,
              );
            }),
          );
          if (result == null) {
            return;
          } else {
            newMarker = null;
            fillMarkers(result);
            setState(() {});
          }
        });
  }

  LatLng azoresCenter = LatLng(38.568217, -28.245459);
  MapController mapController = MapController();
  List<Marker> _markers = [];
  Marker newMarker;

  FlutterMap getMap() {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        onTap: (value) {
          if (newMarker != null) {
            setNewMarker(value);
          }
        },
        minZoom: 6,
        maxZoom: 21,
        zoom: 8,
        center: azoresCenter,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://api.tiles.mapbox.com/v4/"
              "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
          additionalOptions: {
            'accessToken': myMapboxToken,
            'id': 'mapbox.streets',
          },
        ),
        if (newMarker == null) MarkerLayerOptions(markers: _markers),
        if (newMarker != null) MarkerLayerOptions(markers: [newMarker]),
      ],
    );
  }

  fillMarkers(List mapPoints) {
    _markers.clear();
    for (var point in mapPoints) {
      addMarker(LatLng(double.parse(point["Lat"]), double.parse(point["Lng"])),
          point["MyData"], point["Description"]);
    }
    setState(() {});
  }

  addMarker(LatLng _point, String title, String description) {
    _markers.add(Marker(
      width: 25.0,
      height: 25.0,
      point: _point,
      builder: (ctx) => Container(
        child: GestureDetector(
          onTap: () async {
            alertDialog(title, description);
          },
          child: Icon(
            Icons.location_on,
            size: 25,
            color: Colors.green,
          ),
        ),
      ),
    ));
  }

  setNewMarker(LatLng value) {
    newMarker = Marker(
      width: 25.0,
      height: 25.0,
      point: value,
      builder: (ctx) => Container(
        child: Icon(
          Icons.location_on,
          size: 25,
          color: Colors.redAccent,
        ),
      ),
    );
    setState(() {});
  }

  IslandLoc ddIslandsSelected;
  DropdownButton dropIslandMenu() {
    return DropdownButton<IslandLoc>(
      value: ddIslandsSelected,
      icon: Icon(
        Icons.zoom_in,
        color: Colors.black,
      ),
      iconSize: 35,
      onChanged: (IslandLoc newValue) {
        mapController.move(LatLng(newValue.lat, newValue.lon), newValue.zoom);
      },
      items: <IslandLoc>[
        IslandLoc(island: 'Corvo', lat: 39.696422, lon: -31.105885, zoom: 13),
        IslandLoc(
            island: 'Flores', lat: 39.441881, lon: -31.194966, zoom: 11.2),
        IslandLoc(island: 'Faial', lat: 38.582045, lon: -28.712003, zoom: 11),
        IslandLoc(island: 'Pico', lat: 38.466845, lon: -28.292056, zoom: 10),
        IslandLoc(
            island: 'São Jorge', lat: 38.638609, lon: -28.032034, zoom: 10),
        IslandLoc(
            island: 'Graciosa', lat: 39.050803, lon: -28.008608, zoom: 12),
        IslandLoc(
            island: 'Terceira', lat: 38.719470, lon: -27.222096, zoom: 10.4),
        IslandLoc(
            island: 'São Miguel', lat: 37.780274, lon: -25.496629, zoom: 9.5),
        IslandLoc(
            island: 'Santa Maria', lat: 36.976834, lon: -25.096270, zoom: 11.3)
      ].map<DropdownMenuItem<IslandLoc>>((IslandLoc value) {
        return DropdownMenuItem<IslandLoc>(
          value: value,
          child: Text(value.island),
        );
      }).toList(),
    );
  }

  Future<void> alertDialog(String title, String description) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: <Widget>[
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
