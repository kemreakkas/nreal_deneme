// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages, unnecessary_string_interpolations, prefer_final_fields, prefer_interpolation_to_compose_strings, avoid_print, await_only_futures, prefer_typing_uninitialized_variables

import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:motion_sensors/motion_sensors.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

void main() {
  runApp(MaterialApp(
    routes: {
      '/': (context) => const MyApp(),
    },
  ));
}

int? _groupValue = 0;
var s;

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // List<StorageInfo> storageInfo = [];
  Vector3 _accelerometer = Vector3.zero();
  Vector3 _gyroscope = Vector3.zero();
  Vector3 _magnetometer = Vector3.zero();
  Vector3 _userAaccelerometer = Vector3.zero();
  Vector3 _orientation = Vector3.zero();
  Vector3 _absoluteOrientation = Vector3.zero();
  Vector3 _absoluteOrientation2 = Vector3.zero();
  double? _screenOrientation = 0;
  bool kayitaktivite = false;
  bool _switchValue = true;

  @override
  void initState() {
    super.initState();
    motionSensors.gyroscope.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscope.setValues(event.x, event.y, event.z);
      });
    });
    motionSensors.accelerometer.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometer.setValues(event.x, event.y, event.z);
      });
    });
    motionSensors.userAccelerometer.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAaccelerometer.setValues(event.x, event.y, event.z);
      });
    });
    motionSensors.magnetometer.listen((MagnetometerEvent event) {
      setState(() {
        _magnetometer.setValues(event.x, event.y, event.z);
        var matrix =
            motionSensors.getRotationMatrix(_accelerometer, _magnetometer);
        _absoluteOrientation2.setFrom(motionSensors.getOrientation(matrix));
      });
    });
    motionSensors.isOrientationAvailable().then((available) {
      if (available) {
        motionSensors.orientation.listen((OrientationEvent event) {
          setState(() {
            _orientation.setValues(event.yaw, event.pitch, event.roll);
          });
        });
      }
    });
    motionSensors.absoluteOrientation.listen((AbsoluteOrientationEvent event) {
      setState(() {
        _absoluteOrientation.setValues(event.yaw, event.pitch, event.roll);
      });
    });
    motionSensors.screenOrientation.listen((ScreenOrientationEvent event) {
      setState(() {
        _screenOrientation = event.angle;
      });
    });

    super.initState();
  }

  void setUpdateInterval(int? groupValue, int interval) {
    motionSensors.accelerometerUpdateInterval = interval;
    motionSensors.userAccelerometerUpdateInterval = interval;
    motionSensors.gyroscopeUpdateInterval = interval;
    motionSensors.magnetometerUpdateInterval = interval;
    motionSensors.orientationUpdateInterval = interval;
    motionSensors.absoluteOrientationUpdateInterval = interval;
    setState(() {
      _groupValue = groupValue;
    });
  }

  //oluşturulacak dosya yolu
  Future<String> get klasorYolu async {
    Directory? klasor = await getExternalStorageDirectory();
    //  Directory klasor = await getApplicationDocumentsDirectory();
    print("Klasör Yolu: " + klasor!.path);
    return klasor.path;
  }

  //dosya oluşturma
  String olusturulandosya = '';
  Future<File> get dosyaOlustur async {
    if (await Permission.manageExternalStorage.request().isGranted) {
      var olusanDosya = await klasorYolu;
      print('dosya yolu' + olusanDosya.toString());
      olusturulandosya = olusanDosya.toString() + "/logger_nreal.csv";
      return File(olusturulandosya);
    }
    print('dosya yolu oluşturulamadı');
    return File('hatalidosya.txt');
  }

  //dosya okuma
  Future<String> get dosyaOku async {
    try {
      var myDosya = await dosyaOlustur;
      String dosyaIcerik = await myDosya.readAsStringSync();
      return dosyaIcerik;
    } catch (e) {
      return "Hata $e";
    }
  }

  //dosya yazma
  Future<File> dosyayaYaz(String yazilacakDeger) async {
    var myDosya = await dosyaOlustur;
    return myDosya.writeAsString(yazilacakDeger);
  }

  generateCsv(bool k) async {
    List<List> dataRows = <List>[];
    /*List<List<dynamic>> headerRows = <List<dynamic>>[];
     List<dynamic> headerrow = [];
      while (kayitaktivite) {
      List<String> headerdata = [
        "TIME",
        "accelometer.x",
        "accelometer.y",
        "accelometer.z",
        "magnetometer.x",
        "magnetometer.y",
        "magnetometer.z",
        "gyroscope.x",
        "gyroscope.y",
        "gyroscope.z",
      ];
      headerrow.add(headerdata);
      headerRows.add(headerrow);
      Directory? klasor = await getExternalStorageDirectory();
      print("folder opened");
      String directory = klasor!.path.toString();
      String csvData1 = const ListToCsvConverter().convert(headerRows);
      final path = "$directory/logger_nreal.csv";
      print(path);
      final File file = File(path);
      await file.writeAsString(csvData1);
    }*/

    while (k == true) {
      String csvData = const ListToCsvConverter().convert(dataRows);
      Directory? klasor = await getExternalStorageDirectory();
      print("klasör" + klasor.toString());
      String directory = klasor!.path.toString();
      final path = "$directory/logger_nreal.csv";
      print(path);
      final File file = File(path);
      s = file.openWrite();
      List<dynamic> row = [];
      List<String> data = [
        DateTime.now().toString(),
        _accelerometer.x.toStringAsFixed(5),
        _accelerometer.y.toStringAsFixed(5),
        _accelerometer.z.toStringAsFixed(5),
        _magnetometer.x.toStringAsFixed(5),
        _magnetometer.y.toStringAsFixed(5),
        _magnetometer.z.toStringAsFixed(5),
        _gyroscope.x.toStringAsFixed(5),
        _gyroscope.y.toStringAsFixed(5),
        _gyroscope.z.toStringAsFixed(5)
      ];
      row.add(data);
      dataRows.add(row);
      print("in " + kayitaktivite.toString());
      print("in " + k.toString());
      await file.writeAsString(csvData);
      if (kayitaktivite == false) {
        break;
      }
    }
  }

  /////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('nreal deneme app'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Update Interval'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio(
                    value: 1,
                    groupValue: _groupValue,
                    onChanged: (dynamic value) => setUpdateInterval(
                        value, Duration.microsecondsPerSecond ~/ 1),
                  ),
                  const Text("1 FPS"),
                  Radio(
                    value: 2,
                    groupValue: _groupValue,
                    onChanged: (dynamic value) => setUpdateInterval(
                        value, Duration.microsecondsPerSecond ~/ 30),
                  ),
                  const Text("30 FPS"),
                  Radio(
                    value: 3,
                    groupValue: _groupValue,
                    onChanged: (dynamic value) => setUpdateInterval(
                        value, Duration.microsecondsPerSecond ~/ 60),
                  ),
                  const Text("60 FPS"),
                ],
              ),
              const Text('Accelerometer'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('${_accelerometer.x.toStringAsFixed(4)}'),
                  Text('${_accelerometer.y.toStringAsFixed(4)}'),
                  Text('${_accelerometer.z.toStringAsFixed(4)}'),
                ],
              ),
              const Text('Magnetometer'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('${_magnetometer.x.toStringAsFixed(4)}'),
                  Text('${_magnetometer.y.toStringAsFixed(4)}'),
                  Text('${_magnetometer.z.toStringAsFixed(4)}'),
                ],
              ),
              const Text('Gyroscope'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('${_gyroscope.x.toStringAsFixed(4)}'),
                  Text('${_gyroscope.y.toStringAsFixed(4)}'),
                  Text('${_gyroscope.z.toStringAsFixed(4)}'),
                ],
              ),
              const Text('User Accelerometer'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('${_userAaccelerometer.x.toStringAsFixed(4)}'),
                  Text('${_userAaccelerometer.y.toStringAsFixed(4)}'),
                  Text('${_userAaccelerometer.z.toStringAsFixed(4)}'),
                ],
              ),
              const Text('Orientation'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('${degrees(_orientation.x).toStringAsFixed(4)}'),
                  Text('${degrees(_orientation.y).toStringAsFixed(4)}'),
                  Text('${degrees(_orientation.z).toStringAsFixed(4)}'),
                ],
              ),
              const Text('Absolute Orientation'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('${degrees(_absoluteOrientation.x).toStringAsFixed(4)}'),
                  Text('${degrees(_absoluteOrientation.y).toStringAsFixed(4)}'),
                  Text('${degrees(_absoluteOrientation.z).toStringAsFixed(4)}'),
                ],
              ),
              const Text('Orientation (accelerometer + magnetometer)'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                      '${degrees(_absoluteOrientation2.x).toStringAsFixed(4)}'),
                  Text(
                      '${degrees(_absoluteOrientation2.y).toStringAsFixed(4)}'),
                  Text(
                      '${degrees(_absoluteOrientation2.z).toStringAsFixed(4)}'),
                ],
              ),
              const Text('Screen Orientation'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('${_screenOrientation!.toStringAsFixed(4)}'),
                ],
              ),
              ElevatedButton(
                  onPressed: () {
                    kayitaktivite = true;
                    generateCsv(kayitaktivite);
                    print("kayıt başlat" + kayitaktivite.toString());
                  },
                  child: const Text('kayıt başlat')),
              Text(kayitaktivite.toString()),
              ElevatedButton(
                  onPressed: () {
                    kayitaktivite = false;
                    generateCsv(kayitaktivite);
                  },
                  child: const Text('kayıt durdur')),
              ElevatedButton(
                  onPressed: () {
                    print(kayitaktivite.toString());
                  },
                  child: const Text('kayıt yolu gör')),
              CupertinoSwitch(
                value: _switchValue,
                onChanged: (kayitaktivite) {
                  setState(() {
                    generateCsv(kayitaktivite);

                    print("VALUE : $kayitaktivite");
                    _switchValue = kayitaktivite;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
