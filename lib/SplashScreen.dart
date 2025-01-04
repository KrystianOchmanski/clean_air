import 'dart:convert';
import 'dart:developer';
import 'package:clean_air/MyHomePage.dart';
import 'package:clean_air/PermissionScreen.dart';
import 'package:clean_air/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather/weather.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
              color: Color(0xffffffff),
              gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [Color(0xff6671e5), Color(0xff4852d9)])),
        ),
        Align(
          alignment: FractionalOffset.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage('icons/cloud-sun.png'),
              ),
              const Padding(padding: EdgeInsets.only(top: 15.0)),
              Text(Strings.appTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                          fontSize: 42.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white))),
              const Padding(padding: EdgeInsets.only(top: 5.0)),
              Text('Aplikacja do monitorowania \n czystości powietrza',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                          fontSize: 16.0, color: Colors.white))),
            ],
          ),
        ),
        Positioned(
            left: 0,
            bottom: 35,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              child: Text('Przywiewam dane...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w300,
                          color: Colors.white))),
            ))
      ],
    ));
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const PermissionScreen()));
    } else {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        executeOnceAfterBuild();
      });
    }

    return false;
  }

  void executeOnceAfterBuild() async {
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.lowest,
            forceAndroidLocationManager: true,
            timeLimit: const Duration(seconds: 5))
        .then((value) => {loadLocationData(value)})
        .onError((error, stackTrace) => {
              Geolocator.getLastKnownPosition(forceAndroidLocationManager: true)
                  .then((value) => {loadLocationData(value!)})
            });
  }

  loadLocationData(Position value) async {
    var lat = value.latitude;
    var lon = value.longitude;

    WeatherFactory wf = WeatherFactory('9f3eaadd115ca365db18015a401889ee',
        language: Language.POLISH);
    Weather w = await wf.currentWeatherByLocation(lat, lon);
    log(w.toJson().toString());

    var key = 'f16b2dcb4608e1b4350ca3fe70259735df01f5e7';
    String endpoint = 'https://api.waqi.info/feed/';
    var keyword = 'geo:$lat;$lon';
    String url = '$endpoint/$keyword/?token=$key';

    http.Response response = await http.get(Uri.parse(url));
    log(response.body.toString());

    Map<String, dynamic> jsonBody = json.decode(response.body);
    AirQuality aq = AirQuality(jsonBody);

    Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(weather: w, air: aq)));
  }
}

class AirQuality {
  bool isGood = false;
  bool isBad = false;
  String quality = "";
  String advice = "";
  int aqi = 0;
  int pm25 = 0;
  int pm10 = 0;
  String station = "";

  AirQuality(Map<String, dynamic> jsonBody) {
    aqi = int.tryParse(jsonBody['data']['aqi'].toString()) ?? -1;
    pm25 = int.tryParse(jsonBody['data']['iaqi']['pm25']['v'].toString()) ?? -1;
    pm10 = int.tryParse(jsonBody['data']['iaqi']['pm10']['v'].toString()) ?? -1;
    station = jsonBody['data']['city']['name'].toString();
    setupLevel(aqi);
  }

  void setupLevel(int aqi) {
    if (aqi <= 100) {
      quality = "Bardzo dobra";
      advice = "Skorzystaj z dobrego powietrza i wyjdź na spacer";
      isGood = true;
    } else if (aqi <= 150) {
      quality = "Nie za dobra";
      advice = "Jeśli tylko możesz zostań w domu, załatwiaj sprawy online";
      isBad = true;
    } else {
      quality = "Bardzo zła";
      advice = "Zdecydowanie zostań w domu i załatwiaj sprawy online";
    }
  }
}
