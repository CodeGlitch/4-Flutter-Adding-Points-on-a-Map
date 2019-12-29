import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import '../keys.dart';

class NewEntry extends StatelessWidget {
  final LatLng newPoint;
  NewEntry({Key key, @required this.newPoint}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("New Entry"),
        ),
        body: createBody(context));
  }

  final _formKey = GlobalKey<FormState>();
  createBody(BuildContext context) {
    return Form(
        key: _formKey,
        child: ListView(shrinkWrap: true, children: <Widget>[
          Container(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        "latitude: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        newPoint.latitude.toString(),
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: <Widget>[
                      Text(
                        "longitude: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        newPoint.longitude.toString(),
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  title(),
                  SizedBox(height: 5),
                  description(),
                  SizedBox(height: 5),
                  saveDataButton(context),
                ],
              ),
            ),
          ),
        ]));
  }

  saveDataButton(BuildContext context) {
    return Center(
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(5),
        color: Colors.blue,
        child: MaterialButton(
          minWidth: MediaQuery.of(context).size.width -
              (MediaQuery.of(context).size.width * 0.50),
          onPressed: () async {
            if (_formKey.currentState.validate()) {
              List result = await requestNewPoint();
              Navigator.pop(context, result);
            }
          },
          child: Text("Save",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        ),
      ),
    );
  }

  Future<List> requestNewPoint() async {
    Map<String, String> _body = {
      'lat': newPoint.latitude.toString(),
      'lng': newPoint.longitude.toString(),
      'title': _titleController.text,
      'description': _descriptionController.text
    };
    final response = await http.post(myAPIurl + "NewPoint",
        headers: {
          'authorization':
              "Basic " + base64Encode(utf8.encode(myAPIBasicAuthentication)),
          'Accept-Encoding': 'gzip'
        },
        body: _body);

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      return responseJson;
    } else {
      return null;
    }
  }

  final TextEditingController _titleController = TextEditingController();
  title() {
    return TextFormField(
      controller: _titleController,
      validator: (value) {
        if (value.isEmpty) {
          return "Please fill the title";
        }
        return null;
      },
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
          hintText: "Title",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
    );
  }

  final TextEditingController _descriptionController = TextEditingController();
  description() {
    return TextFormField(
      maxLines: 5,
      controller: _descriptionController,
      validator: (value) {
        if (value.isEmpty) {
          return "Please fill the description";
        }
        return null;
      },
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
          hintText: "Description",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
    );
  }
}
