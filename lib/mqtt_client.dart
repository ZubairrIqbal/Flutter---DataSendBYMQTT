// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:sensorflutterapp/colors.dart';
import 'package:sensorflutterapp/componants/card_componant.dart';
import 'package:sensorflutterapp/componants/linechart.dart';
import 'package:quickalert/quickalert.dart';

class SoilIntegratorApp extends StatelessWidget {
  const SoilIntegratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soil Monitoring',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SoilMonitoringScreen(),
    );
  }
}

class SoilMonitoringScreen extends StatefulWidget {
  const SoilMonitoringScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SoilMonitoringScreenState createState() => _SoilMonitoringScreenState();
}

class _SoilMonitoringScreenState extends State<SoilMonitoringScreen> {
  final String broker = '10.0.0.153';
  final String topic = 'sensor/data';
  final String clientId = 'flutter_client';
  late MqttServerClient client;

  @override
  void initState() {
    super.initState();
    _setupMqttClient();
  }

  void _showSuccesAlert() {
    QuickAlert.show(
        context: context,
        title: 'Data Sent',
        text: 'Data has been Succesfully sent',
        confirmBtnColor: appColor,
        autoCloseDuration: const Duration(seconds: 10),
        type: QuickAlertType.success);
  }

  void _showWarningAlert() {
    QuickAlert.show(
        context: context,
        title: 'Oops!',
        text: 'Data did not send',
        confirmBtnColor: const Color.fromARGB(255, 224, 47, 34),
        autoCloseDuration: const Duration(seconds: 10),
        type: QuickAlertType.error);
  }

  Future<void> _setupMqttClient() async {
    client = MqttServerClient(broker, clientId)
      ..logging(on: true)
      ..onConnected = _onConnected
      ..onDisconnected = _onDisconnected
      ..onSubscribed = _onSubscribed;
    client.port = 1883;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillTopic('willtopic')
        .withWillMessage('Client disconnected unexpectedly')
        .startClean()
        .withWillQos(MqttQos.exactlyOnce);

    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      print('Connection failed: $e');
      client.disconnect();
    }
  }

  void _onConnected() {
    print('Connected to MQTT broker');
  }

  void _onDisconnected() {
    print('Disconnected from MQTT broker');
  }

  void _onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

  double temperature = 25.0;
  double moisture = 30.0;
  double pH = 50;

  void _sendSensorData() {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();

      // Example sensor data
      final sensorData = {
        'temperature': 25.5,
        'humidity': 65.2,
        'pH': 7.4,
        'soilMoisture': 32.5
      };
      final String jsonData = jsonEncode(sensorData);
      builder.addString(jsonData);

      client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
      _showSuccesAlert();
      print('Sensor data sent: $jsonData');
    } else {
      _showWarningAlert();
    }
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 221, 220, 220),
      appBar: AppBar(
        title: Text(
          'Soil Monitoring',
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
        backgroundColor: appColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CardComponant(label: 'Temperature', value: temperature, unit: '°C'),
                CardComponant(label: 'Moisture', value: moisture, unit: '%'),
                CardComponant(label: 'pH Level', value: pH, unit: ''),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendSensorData,
              style: ElevatedButton.styleFrom(
                backgroundColor: appColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text(
                'Send Data to Cloud',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Linechart(temperature: temperature, moisture: moisture, pH: pH)
          ],
        ),
      ),
    );
  }
}
