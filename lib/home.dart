import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final dbRef = FirebaseDatabase.instance.ref();
  bool value = false;

  onUpdate() {
    setState(() {
      value = !value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Fire Detection Smart Home",
                style: TextStyle(
                    fontSize: 30, height: 1, fontWeight: FontWeight.w500),
              ),
              const Text(
                "Stay Safe",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                  flex: 6,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.asset(
                        "assets/img2.png",
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ))),
              const SizedBox(
                height: 10,
              ),
              StreamBuilder(
                  stream: dbRef.onValue,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        !snapshot.hasError &&
                        snapshot.data?.snapshot.value != null) {
                      final jsonString =
                          jsonEncode(snapshot.data!.snapshot.value);

                      var sensorData =
                          SensorData.fromJson(jsonDecode(jsonString));
                      return Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Cards(
                                icon: FontAwesomeIcons.fire,
                                on: value,
                                status: sensorData.api == '1'
                                    ? "Fire Not Detected"
                                    : "Fire Detected",
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Cards(
                                icon: FontAwesomeIcons.wind,
                                on: value,
                                status: sensorData.api == '1'
                                    ? "Gas Not Detected"
                                    : "Gas Not Detected",
                              ),
                            ],
                          ));
                    }
                    return const SizedBox(
                      child: Text('Kososng'),
                    );
                  }),
              InkWell(
                onTap: () {
                  onUpdate();
                  writeData();
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: 40,
                  decoration: BoxDecoration(
                      color: value
                          ? Colors.black.withOpacity(.1)
                          : const Color(0xff0A0A0A),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.powerOff,
                        size: 18,
                        color: value ? Colors.black : Colors.white,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        value ? "Turn Off Sensor" : "Turn On Sensor",
                        style: TextStyle(
                            color: value ? Colors.black : Colors.white),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> writeData() async {
    dbRef.child("state").set({"switch": value});
  }
}

class SensorData {
  final String api;
  final String gas;

  SensorData({required this.api, required this.gas});

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      api: json['api'].toString(),
      gas: json['gas'].toString(),
    );
  }

  @override
  String toString() {
    return 'SensorData{api: $api, gas: $gas}';
  }
}

class Cards extends StatelessWidget {
  final bool? on;
  final IconData? icon;
  final String? status;
  const Cards({super.key, this.icon, this.on, this.status});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: on == true
                ? Colors.black.withOpacity(.1)
                : const Color(0xff0A0A0A),
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                size: 30, color: on == true ? Colors.black : Colors.white),
            const Spacer(),
            Text(
              status ?? "",
              style: TextStyle(
                  fontSize: 20,
                  color: on == true ? Colors.black : Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
