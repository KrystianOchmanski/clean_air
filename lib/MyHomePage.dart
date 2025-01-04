import 'package:clean_air/AirScreen.dart';
import 'package:clean_air/SplashScreen.dart';
import 'package:clean_air/WeatherScreen.dart';
import 'package:flutter/material.dart';
import 'package:weather/weather.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.weather, required this.air});

  final Weather weather;
  final AirQuality air;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _currentIndex = 0;
  // ignore: prefer_typing_uninitialized_variables
  var screens;

  @override
  void initState() {
    screens = [
      AirScreen(air: widget.air),
      WeatherScreen(weather: widget.weather)
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black45,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: 38.0,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() {
                _currentIndex = index;
              }),
          items: [
            BottomNavigationBarItem(
                icon: Image.asset("icons/house.png"),
                label: "Powietrze",
                activeIcon: Image.asset("icons/house-checked.png")),
            BottomNavigationBarItem(
                icon: Image.asset("icons/cloud.png"),
                label: "Pogoda",
                activeIcon: Image.asset("icons/cloud-checked.png"))
          ]),
    );
  }
}
