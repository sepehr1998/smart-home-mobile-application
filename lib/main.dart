import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          // When navigating to the "/second" route, build the SecondScreen widget.
          '/second': (context) => livingroom(),
          '/third': (context) => statspage(),
        },
        home: dashboard());
  }
}

class dashboard extends StatefulWidget {
  @override
  _dashboardState createState() => _dashboardState();
}
String token;

Future<String> login() async {
  var url = Uri.parse('http://smart-home-server-mr-os7798-dev.apps.sandbox-m2.ll9k.p1.openshiftapps.com/api/authenticate');
    var response = await http.post(url,
        body: jsonEncode({'username': 'user', 'password': 'user'}),
        headers: {"content-type": "application/json"});
    return jsonDecode(response.body)['id_token'];
}


Future<String> getToken() async {
  if (token == null ) {
    token = await login();
  }
    return token;
}
Future<bool> trigger(int id, int value1) async {
  var url = Uri.parse('http://smart-home-server-mr-os7798-dev.apps.sandbox-m2.ll9k.p1.openshiftapps.com/api/data');
  var token = await getToken();
  var response = await http.post(url,
          body: jsonEncode({'dataTemplateId': id, 'value': value1}),
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer ' + token,
            "content-type": "application/json"
          });
  if (response.statusCode == 401) {
    token = await getToken();
    await http.post(url,
        body: jsonEncode({'dataTemplateId': id, 'value': value1}),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ' + token,
          "content-type": "application/json"
        });
  }
  return value1 == 1 ? true : false;
}

Future<String> getTemp() async {
  var url = Uri.parse(
      'http://smart-home-server-mr-os7798-dev.apps.sandbox-m2.ll9k.p1.openshiftapps.com/api/data/4f04325e-ab00-4063-bfbd-5cf2e6e6924a/CELSIUS');
  var token = await getToken();
  var response = await http.get(url, headers: {
    HttpHeaders.authorizationHeader: 'Bearer ' + token,
    "content-type": "application/json"
  });
  return jsonDecode(response.body)['value'].toString();
}

FutureBuilder<String> getTempText(){

  return FutureBuilder(future: getTemp(),builder: (context, snapshot) {
    if (snapshot.hasError)
      print(snapshot.error);
    return snapshot.hasData
        ? Text(snapshot.data + "°C",
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
        ))
        : Text("NA°C",
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
        ));
  },);

}
Future<String> getBill() async {
  var url = Uri.parse(
      'http://smart-home-server-mr-os7798-dev.apps.sandbox-m2.ll9k.p1.openshiftapps.com/api/data/bill/');
  var token = await getToken();
  var response = await http.get(url, headers: {
    HttpHeaders.authorizationHeader: 'Bearer ' + token,
    "content-type": "application/json"
  });
  return jsonDecode(response.body)['value'].toString();
}


FutureBuilder<String> getBillText(){

  return FutureBuilder(future: getBill(),builder: (context, snapshot) {
    if (snapshot.hasError)
      print(snapshot.error);
    return snapshot.hasData
        ? Text(snapshot.data,
        style: TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ))
        : Text("NA",
        style: TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ));
  },);

}







Future<String> getCurrent() async {
  var url = Uri.parse(
      'http://smart-home-server-mr-os7798-dev.apps.sandbox-m2.ll9k.p1.openshiftapps.com/api/data/4c47e53a-d1ab-11eb-b8bc-0242ac130003/AMPERE');
  var token = await getToken();
  var response = await http.get(url, headers: {
    HttpHeaders.authorizationHeader: 'Bearer ' + token,
    "content-type": "application/json"
  });
  return jsonDecode(response.body)['value'].toString();
}

FutureBuilder<String> getCurrentText(){

  return FutureBuilder(future: getCurrent(),builder: (context, snapshot) {
    if (snapshot.hasError)
      print(snapshot.error);
    return snapshot.hasData
        ? Container(
      margin: EdgeInsets.only(top: 20),
      height: 100,
        child:
        CircularPercentIndicator(
          radius: 100.0,
          animation: true,
          animationDuration: 1200,
          lineWidth: 5.0,
          percent: double.parse(snapshot.data)/30.0,
          center: new Container(
              child: Text(
                snapshot.data,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              )
          ),
          progressColor: Color(0xffcaac76),
        )
    )
        : Container(
        height: 100,
      margin: EdgeInsets.only(top: 20),
      child:
      CircularPercentIndicator(
        radius: 100.0,
        animation: true,
        animationDuration: 1200,
        lineWidth: 5.0,
        percent: 0.0,
        center: new Container(
            child: Text(
              "NA",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
            )
        ),
        progressColor: Color(0xffcaac76),
      )
    );
  },);

}


class _dashboardState extends State<dashboard> {
  @override
  final Duration timerDuration = Duration(seconds: 10,);
  bool selected = true;



  FutureBuilder lt = getTempText();
  FutureBuilder current = getCurrentText();


  _dashboardState();

  Widget build(BuildContext context) {

    Timer _timer = new Timer.periodic(
        timerDuration,
            (Timer timer) =>
            setState(() {
             lt = getTempText();
              return lt;
            }));

    Timer current_timer = new Timer.periodic(
        timerDuration,
            (Timer timer) =>
            setState(() {
              current = getCurrentText();
              return current;
            }));


    return Scaffold(
      drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: Container(
            color: Color(0xff282a2e),
            child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                  image: DecorationImage(
                colorFilter: new ColorFilter.mode(
                    Colors.black.withOpacity(0.5), BlendMode.dstATop),
                image: AssetImage("assets/outside.jpg"),
                fit: BoxFit.cover,
              )),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        image: DecorationImage(
                          image: AssetImage("assets/user.jpg"),
                          fit: BoxFit.cover,
                        )),
                    width: 60,
                    height: 60,
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text(
                        "Sepehr Samadi",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Text(
                        "Household",
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ))
                ],
              ),
            ),
            Container(
                child: Column(
              children: [
                ListTile(
                  title: Text('Dashboard',
                      style: TextStyle(
                        color: Color(0xffffffff),
                      )),
                  leading: Icon(
                    Icons.dashboard,
                    color: Color(0xffcaac76),
                  ),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text(
                    'Living Room',
                    style: TextStyle(
                      color: Color(0xffffffff),
                    ),
                  ),
                  leading: Icon(
                    Icons.weekend_outlined,
                    color: Color(0xffcaac76),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => livingroom()),
                    );
                  },
                ),
                ListTile(
                  title: Text(
                    'Kitchen',
                    style: TextStyle(
                      color: Color(0xffffffff),
                    ),
                  ),
                  leading: Icon(
                    Icons.kitchen,
                    color: Color(0xffcaac76),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => statspage()),
                    );
                  },
                ),
                ListTile(
                  title: Text(
                    'Stats',
                    style: TextStyle(
                      color: Color(0xffffffff),
                    ),
                  ),
                  leading: Icon(
                    Icons.bar_chart,
                    color: Color(0xffcaac76),
                  ),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => statspage()),
                    );                  },
                ),
                ListTile(
                  title: Text(
                    'Settings',
                    style: TextStyle(
                      color: Color(0xffffffff),
                    ),
                  ),
                  leading: Icon(
                    Icons.settings,
                    color: Color(0xffcaac76),
                  ),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.pop(context);
                  },
                ),
              ],
            ))
          ],
        ),
      )),
      appBar: AppBar(
        backgroundColor: Color(0xff282a2e),
        title: Center(
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(right: 10, left: 50),
                child: Icon(Icons.dashboard),
              ),
              Container(
                child: Text(
                  "Dashboard",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 50),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    image: DecorationImage(
                      image: AssetImage("assets/user.jpg"),
                      fit: BoxFit.cover,
                    )),
                width: 35,
                height: 35,
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: Color(0xff282a2e),
        child: Column(
          children: [
            Container(
              color: Color(0xff282a2e),
              margin: EdgeInsets.only(top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              )
                            ],
                            color: Color(0xff393a3e),
                            borderRadius: BorderRadius.circular(20)),
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(right: 20),
                        padding: EdgeInsets.only(left: 10, top: 15),
                        width: 150,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 115,
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Color(0xff23262e),
                                            border: Border.all(
                                                width: 10,
                                                color: Color(0xff434549)),
                                            borderRadius:
                                                BorderRadius.circular(2000)),
                                        width: 60,
                                        height: 60,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selected = !selected;
                                          });
                                        },
                                        child: AnimatedContainer(
                                          alignment: Alignment.topLeft,
                                          margin: EdgeInsets.only(
                                              left: 15, top: 15),
                                          padding:
                                              EdgeInsets.only(left: 8, top: 8),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment(0.8, 0.0),
                                                // 10% of the width, so there are ten blinds.
                                                colors: <Color>[
                                                  Color(0xffd0b27c),
                                                  Color(0xffbf9b63)
                                                ],
                                                // red to yellow
                                                tileMode: TileMode
                                                    .repeated, // repeats the gradient over the canvas
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(2000)),
                                          width: selected ? 90.0 : 30.0,
                                          height: selected ? 30.0 : 90.0,
                                          duration: const Duration(seconds: 0),
                                          curve: Curves.linear,
                                          child: Icon(Icons.lock, size: 15),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 80),
                              child: DottedBorder(
                                borderType: BorderType.Circle,
                                color: Color(0xff535559),
                                strokeWidth: 1,
                                child: Container(
                                  padding: EdgeInsets.only(right: 80),
                                  decoration: BoxDecoration(
                                      color: Color(0xff393a3e),
                                      borderRadius: BorderRadius.circular(20)),
                                  width: 5,
                                  height: 5,
                                ),
                              ),
                            ),
                            Container(
                                margin: EdgeInsets.only(
                                    right: 80, top: 15, bottom: 15),
                                child: Text("Unlock",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xff535559),
                                    ))),
                            Container(
                                margin: EdgeInsets.only(right: 80, top: 10),
                                child: Text(
                                  "doors",
                                  style: TextStyle(
                                      fontSize: 20, color: Color(0xff6c6b70)),
                                )),
                            Container(
                                margin: EdgeInsets.only(
                                    right: 40, top: 5, bottom: 10),
                                child: Text(
                                  "Locked",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Color(0xff9c9c9e),
                                      fontWeight: FontWeight.bold),
                                ))
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                      width: 150,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xff393a3e),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          current,
                          Container(
                            alignment: Alignment.center,
                            width: 150,
                            color: Color(0xff393a3e),
                            padding: EdgeInsets.only(top: 40, left: 20),
                            child: Text(
                              "Power Consumption",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(),
                            width: 150,
                            padding:
                                EdgeInsets.only(top: 10, left: 20, bottom: 30),
                            child: Text(
                              "Amperes",
                              style: TextStyle(
                                color: Color(0xffcaac76),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ))
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () {
                      setState(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => livingroom()),
                        );
                      });
                    },
                    child: Container(
                        margin: EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            )
                          ],
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: AssetImage("assets/livingroomdark.jpg"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        height: 200,
                        width: 320,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      margin:
                                          EdgeInsets.only(top: 15, left: 15),
                                      child: Text(
                                        "Living Room",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Container(
                                      margin:
                                          EdgeInsets.only(top: 15, left: 140),
                                      child: lt
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(children: [
                              Stack(children: [
                                Container(
                                    margin: EdgeInsets.only(top: 110, left: 20),
                                    decoration: BoxDecoration(
                                        color: Color(0xaf23262e),
                                        borderRadius:
                                            BorderRadius.circular(2000)),
                                    width: 120,
                                    height: 40,
                                    child: Container(
                                        margin:
                                            EdgeInsets.only(top: 13, left: 45),
                                        child: Text(
                                          "Amperes",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ))),
                                Container(
                                    margin: EdgeInsets.only(top: 115, left: 25),
                                    decoration: BoxDecoration(
                                        color: Color(0xffc8a871),
                                        borderRadius:
                                            BorderRadius.circular(2000)),
                                    width: 30,
                                    height: 30,
                                    child: Row(
                                      children: [
                                        Container(
                                            margin: EdgeInsets.only(left: 10),
                                            child: Text(
                                              "3",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                              ),
                                            ))
                                      ],
                                    )),
                              ])
                            ])
                          ],
                        )))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    margin: EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        )
                      ],
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage("assets/kitchen.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: 200,
                    width: 320,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 15, left: 15),
                                  child: Text(
                                    "Kitchen",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 15, left: 180),
                                  child: Text(
                                    "23°C",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(children: [
                          Stack(children: [
                            Container(
                                margin: EdgeInsets.only(top: 110, left: 20),
                                decoration: BoxDecoration(
                                    color: Color(0xaf23262e),
                                    borderRadius: BorderRadius.circular(2000)),
                                width: 120,
                                height: 40,
                                child: Container(
                                    margin: EdgeInsets.only(top: 13, left: 45),
                                    child: Text(
                                      "Amperes",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ))),
                            Container(
                                margin: EdgeInsets.only(top: 115, left: 25),
                                decoration: BoxDecoration(
                                    color: Color(0xffc8a871),
                                    borderRadius: BorderRadius.circular(2000)),
                                width: 30,
                                height: 30,
                                child: Row(
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(
                                          "7",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                          ),
                                        ))
                                  ],
                                )),
                          ])
                        ])
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class livingroom extends StatefulWidget {
  @override
  _livingroomState createState() => _livingroomState();
}

class _livingroomState extends State<livingroom> {
  int valueHolder = 50;
  double temp = 25.0;
  bool status = false;
  bool lamp1 = false;
  bool lamp2 = false;
  bool lamp3 = false;
  bool lamp4 = false;
  bool heat = true;
  bool snow = false;
  bool humid = false;
  bool wind = false;
  bool pump = false;
  bool ac_on = false;
  bool fast = false;
  Timer ac_timer;

  Image lampon = Image.asset("assets/lighton.png");
  Image lampoff = Image.asset("assets/lightoff.png");

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: new Drawer(
            // Add a ListView to the drawer. This ensures the user can scroll
            // through the options in the drawer if there isn't enough vertical
            // space to fit everything.
            child: Column(
          children: [
            Container(
              color: Color(0xff282a2e),
              // height: 830,
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Container(
                        margin: EdgeInsets.only(top: 30),
                        color: Color(0xff282a2e),
                        child: TabBar(
                          indicatorColor: Color(0xffc8a871),
                          indicator: UnderlineTabIndicator(
                            borderSide: BorderSide(
                                color: Color(0xffc8a871), width: 2.0),
                          ),
                          tabs: [
                            Tab(
                              text: "AC Unit",
                            ),
                            Tab(
                              text: "Lights",
                            ),
                          ],
                        )),
                    Container(
                        width: 300,
                        height: 750,
                        child: TabBarView(children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 80, left: 50),
                                child: Text(
                                  "AC Unit",
                                  style: TextStyle(
                                    color: Color(0xffffffff),
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 30, left: 50),
                                child: Text(
                                  "LG Split Unit",
                                  style: TextStyle(
                                    color: Color(0xffffffff),
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.only(left: 85, top: 80),
                                  height: 200,
                                  child: Image.asset("assets/achalf.png")),
                              Container(
                                  margin: EdgeInsets.only(top: 100, left: 50),
                                  child: Row(
                                    children: [
                                      Container(
                                          child: Icon(
                                        Icons.power,
                                        color: Color(0xffc8a871),
                                      )),
                                      Container(
                                          child: Text(
                                        "10 Amperes",
                                        style: TextStyle(
                                          color: Color(0xffffffff),
                                          fontSize: 16,
                                        ),
                                      ))
                                    ],
                                  )),
                              Container(
                                  margin: EdgeInsets.only(top: 30, left: 50),
                                  child: Row(
                                    children: [
                                      Container(
                                          child: Icon(
                                        Icons.bar_chart,
                                        color: Color(0xffc8a871),
                                      )),
                                      Container(
                                          child: Text(
                                        "60% of Room Consumption",
                                        style: TextStyle(
                                          color: Color(0xffffffff),
                                          fontSize: 16,
                                        ),
                                      ))
                                    ],
                                  )),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 80, left: 50),
                                child: Text(
                                  "Lights",
                                  style: TextStyle(
                                    color: Color(0xfffffffff),
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 30, left: 50),
                                child: Text(
                                  "LED Lights",
                                  style: TextStyle(
                                    color: Color(0xfffffffff),
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.only(left: 200),
                                  height: 400,
                                  width: 300,
                                  child: Image.asset("assets/lbulbhalf.png")),
                              Container(
                                  margin: EdgeInsets.only(left: 50),
                                  child: Row(
                                    children: [
                                      Container(
                                          child: Icon(
                                        Icons.power,
                                        color: Color(0xffc8a871),
                                      )),
                                      Container(
                                          child: Text(
                                        "5 Amperes",
                                        style: TextStyle(
                                          color: Color(0xfffffffff),
                                          fontSize: 16,
                                        ),
                                      ))
                                    ],
                                  )),
                              Container(
                                  margin: EdgeInsets.only(top: 30, left: 50),
                                  child: Row(
                                    children: [
                                      Container(
                                          child: Icon(
                                        Icons.bar_chart,
                                        color: Color(0xffc8a871),
                                      )),
                                      Container(
                                          child: Text(
                                        "40% of Room Consumption",
                                        style: TextStyle(
                                          color: Color(0xffffffff),
                                          fontSize: 16,
                                        ),
                                      ))
                                    ],
                                  )),
                            ],
                          ),
                        ]))
                  ],
                ),
              ),
            ),
          ],
        )),
        appBar: AppBar(
          backgroundColor: Color(0xff282a2e),
          leading: GestureDetector(
            onTap: () => _scaffoldKey.currentState.openDrawer(),
            child: Container(
              margin: EdgeInsets.only(left: 20),
              child: Image.asset("assets/gauge.png"),
            ),
          ),
          title: Center(
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 10, left: 50),
                  child: Icon(
                    Icons.weekend_outlined,
                  ),
                ),
                Container(
                  child: Text(
                    "Living Room",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 70),
                  child: GestureDetector(
                    onTap: () => launch('http://home.lan:8081'),
                  child: Icon(Icons.photo_camera_front),
                  ),
                  width: 35,
                  height: 35,
                ),
              ],
            ),
          ),
        ),
        body: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                    color: Color(0xff282a2e),
                    child: TabBar(
                      indicatorColor: Color(0xffc8a871),
                      indicator: CircleTabIndicator(
                          color: Color(0xffc8a871), radius: 4),
                      tabs: [
                        Tab(
                          text: "AC Unit",
                        ),
                        Tab(
                          text: "Lights",
                        ),
                      ],
                    )),
                Container(
                    height: 700,
                    width: 700,
                    color: Color(0xff282a2e),
                    child: Container(
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                            color: Color(0xff2b2d30),
                            border:
                                Border.all(color: Color(0xffc8a871), width: 2),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(40),
                              topLeft: Radius.circular(40),
                            )),
                        child: TabBarView(
                          children: [
                            Container(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  margin: EdgeInsets.only(top: 20, left: 50),
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment(0.2, 0.0),
                                        // 10% of the width, so there are ten blinds.
                                        colors: <Color>[
                                          Color(0xffd0b27c),
                                          Color(0xffbf9b63)
                                        ],
                                        // red to yellow
                                        tileMode: TileMode
                                            .repeated, // repeats the gradient over the canvas
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(2000)),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (snow == true && valueHolder == 0) {
                                          trigger(79, pump ? 0 : 1);
                                          pump = !pump;
                                          ac_timer = new Timer(const Duration(milliseconds: 1000), () {
                                            setState(() {
                                              trigger(80, ac_on ? 0 : 1);
                                              ac_on = !ac_on;
                                              fast = false;
                                            });
                                          });

                                        }
                                      });
                                    },
                                    child: Icon(Icons.power_settings_new),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Color(0xffc8a871),
                                                width: 2),
                                            borderRadius:
                                                BorderRadius.circular(2000),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.7),
                                                  spreadRadius: 2,
                                                  blurRadius: 7,
                                                  offset: Offset(0, 1))
                                            ],
                                          ),
                                          margin: EdgeInsets.only(
                                              right: 40, left: 30),
                                          padding: EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Text(
                                            "-",
                                            style: TextStyle(
                                                color: Color(0xffc8a871),
                                                fontSize: 40),
                                          ),
                                        ),
                                        Container(
                                            width: 180,
                                            height: 180,
                                            margin: EdgeInsets.only(top: 10),
                                            decoration: BoxDecoration(
                                              gradient: RadialGradient(
                                                radius: 0.4,
                                                colors: <Color>[
                                                  Color(0xFF69686d),
                                                  Color(0xFFfafafa),
                                                ], // red to yellow
                                                tileMode: TileMode
                                                    .repeated, // repeats the gradient over the canvas
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(2000),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.white
                                                        .withOpacity(0.7),
                                                    spreadRadius: 2,
                                                    blurRadius: 7,
                                                    offset: Offset(0, 1))
                                              ],
                                            ),
                                            child: SleekCircularSlider(
                                                min: 18,
                                                max: 30,
                                                initialValue: 25,
                                                appearance:
                                                    CircularSliderAppearance(
                                                        customColors:
                                                            CustomSliderColors(
                                                          progressBarColors: <
                                                              Color>[
                                                            Color(0xff282a2e),
                                                            Color(0xff282a2e),
                                                          ],
                                                          trackColor:
                                                              Color(0xffc8a871),
                                                        ),
                                                        infoProperties:
                                                            InfoProperties(
                                                                mainLabelStyle:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 26,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                modifier:
                                                                    (temp) {
                                                                  return temp
                                                                          .toInt()
                                                                          .toString() +
                                                                      "°C";
                                                                })),
                                                onChange: (temp) {
                                                  print(temp);
                                                })),
                                        Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Color(0xffc8a871),
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(2000),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.7),
                                                    spreadRadius: 2,
                                                    blurRadius: 7,
                                                    offset: Offset(0, 1))
                                              ],
                                            ),
                                            margin: EdgeInsets.only(left: 40),
                                            padding: EdgeInsets.only(
                                                left: 10, right: 10),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  temp += 1;
                                                });
                                              },
                                              child: Text(
                                                "+",
                                                style: TextStyle(
                                                    color: Color(0xffc8a871),
                                                    fontSize: 40),
                                              ),
                                            )),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 50, top: 10, right: 50),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                      width: 50,
                                                      height: 50,
                                                      margin: EdgeInsets.only(
                                                          top: 10),
                                                      child: Image.asset(
                                                          "assets/fanmin.png")),
                                                  Container(
                                                    width: 50,
                                                    height: 50,
                                                    margin: EdgeInsets.only(
                                                        left: 80, top: 10),
                                                    child: Image.asset(
                                                        "assets/fanmed.png"),
                                                  ),
                                                  Container(
                                                    width: 50,
                                                    height: 50,
                                                    margin: EdgeInsets.only(
                                                        left: 70, top: 10),
                                                    child: Image.asset(
                                                        "assets/fanhigh.png"),
                                                  )
                                                ],
                                              ),
                                              Container(
                                                  child: Slider(
                                                      value: valueHolder
                                                          .toDouble(),
                                                      min: 0,
                                                      max: 100,
                                                      divisions: 2,
                                                      activeColor:
                                                          Color(0xffc8a871),
                                                      inactiveColor:
                                                          Colors.grey,
                                                      onChanged:
                                                          (double newValue) {
                                                        setState(() {
                                                          valueHolder =
                                                              newValue.round();
                                                        });
                                                        if (valueHolder == 0)
                                                          trigger(81, 0);
                                                        else if (valueHolder == 50)
                                                          trigger(81, 1);
                                                      },
                                                      semanticFormatterCallback:
                                                          (double newValue) {
                                                        return '${newValue.round()}';
                                                      })),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                                margin: EdgeInsets.only(
                                                    left: 50, top: 80),
                                                child: Text(
                                                  'From: ',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18),
                                                )),
                                            Container(
                                                decoration: BoxDecoration(
                                                    color: Color(0xff69686d),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                margin: EdgeInsets.only(
                                                    left: 10, top: 80),
                                                width: 60,
                                                height: 30,
                                                padding:
                                                    EdgeInsets.only(left: 7),
                                                alignment: Alignment.center,
                                                child: DateTimePicker(
                                                  type: DateTimePickerType.time,
                                                  cursorColor:
                                                      Colors.transparent,
                                                )),
                                            Container(
                                                margin: EdgeInsets.only(
                                                    left: 50, top: 80),
                                                child: Text(
                                                  'To: ',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18),
                                                )),
                                            Container(
                                                decoration: BoxDecoration(
                                                    color: Color(0xff69686d),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                margin: EdgeInsets.only(
                                                    left: 10, top: 80),
                                                width: 60,
                                                height: 30,
                                                padding:
                                                    EdgeInsets.only(left: 7),
                                                alignment: Alignment.center,
                                                child: DateTimePicker(
                                                  type: DateTimePickerType.time,
                                                  cursorColor:
                                                      Colors.transparent,
                                                )),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  heat = true;
                                                  snow = false;
                                                  humid = false;
                                                  wind = false;
                                                });
                                              },
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    top: 50,
                                                    left: 20,
                                                    right: 20),
                                                padding: EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    color: heat
                                                        ? Color(0xff69686d)
                                                        : Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40)),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      child: Image.asset(
                                                          "assets/heatselect.png"),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          left: 10),
                                                      child: Text(
                                                        heat ? "Heat" : "",
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xffc8a871),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  snow = true;
                                                  heat = false;
                                                  humid = false;
                                                  wind = false;
                                                });
                                              },
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    top: 50, right: 20),
                                                padding: EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    color: snow
                                                        ? Color(0xff69686d)
                                                        : Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40)),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      child: Image.asset(
                                                          "assets/snowselect.png"),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          left: 10),
                                                      child: Text(
                                                        snow ? "Cool" : "",
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xffc8a871),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  humid = true;
                                                  heat = false;
                                                  snow = false;
                                                  wind = false;
                                                });
                                              },
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    top: 50, right: 10),
                                                padding: EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    color: humid
                                                        ? Color(0xff69686d)
                                                        : Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40)),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      child: Image.asset(
                                                          "assets/humidselect.png"),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          left: 10),
                                                      child: Text(
                                                        humid ? "Humid" : "",
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xffc8a871),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  humid = false;
                                                  heat = false;
                                                  snow = false;
                                                  wind = true;
                                                });
                                              },
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    top: 50, right: 10),
                                                padding: EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    color: wind
                                                        ? Color(0xff69686d)
                                                        : Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40)),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      child: Image.asset(
                                                          "assets/windselect.png"),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          left: 10),
                                                      child: Text(
                                                        wind ? "Fan" : "",
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xffc8a871),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            )),
                            Container(
                                child: Row(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                        margin:
                                            EdgeInsets.only(top: 40, left: 40),
                                        width: 150,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Color(0xff393a3e),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: Offset(0, 2),
                                            )
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 150,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    trigger(77, lamp1 ? 0 : 1);
                                                    lamp1 = !lamp1;
                                                  });
                                                },
                                                child: lamp1 ? lampon : lampoff,
                                              ),
                                            ),
                                            Container(
                                                margin:
                                                    EdgeInsets.only(left: 15),
                                                child: Text(
                                                  "lamp 1",
                                                  style: TextStyle(
                                                    color: Color(0xff7b7b7f),
                                                    fontSize: 22,
                                                  ),
                                                )),
                                            Container(
                                                margin: EdgeInsets.only(
                                                    left: 15, top: 5),
                                                child: Text(
                                                  lamp1 ? "ON" : "OFF",
                                                  style: TextStyle(
                                                    color: lamp1
                                                        ? Color(0xffc8a871)
                                                        : Color(0xff7b7b7f),
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ))
                                          ],
                                        )),
                                    Container(
                                        margin:
                                            EdgeInsets.only(top: 20, left: 40),
                                        width: 150,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Color(0xff393a3e),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: Offset(0, 2),
                                            )
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 150,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    trigger(82, lamp3 ? 0 : 1);
                                                    lamp3 = !lamp3;                                                  });
                                                },
                                                child: lamp3 ? lampon : lampoff,
                                              ),
                                            ),
                                            Container(
                                                margin:
                                                    EdgeInsets.only(left: 15),
                                                child: Text(
                                                  "lamp 3",
                                                  style: TextStyle(
                                                    color: Color(0xff7b7b7f),
                                                    fontSize: 22,
                                                  ),
                                                )),
                                            Container(
                                                margin: EdgeInsets.only(
                                                    left: 15, top: 5),
                                                child: Text(
                                                  lamp3 ? "ON" : "OFF",
                                                  style: TextStyle(
                                                    color: lamp3
                                                        ? Color(0xffc8a871)
                                                        : Color(0xff7b7b7f),
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ))
                                          ],
                                        ))
                                  ],
                                ),
                                Column(
                                  children: [
                                    Container(
                                      margin:
                                          EdgeInsets.only(top: 40, left: 30),
                                      child: FlutterSwitch(
                                        width: 125.0,
                                        height: 55.0,
                                        valueFontSize: 25.0,
                                        toggleSize: 45.0,
                                        value: status,
                                        borderRadius: 30.0,
                                        padding: 8.0,
                                        activeColor: Color(0xffc8a871),
                                        inactiveColor: Color(0xff393a3e),
                                        activeIcon: Icon(Icons.wb_sunny),
                                        inactiveIcon:
                                            Icon(Icons.wb_sunny_outlined),
                                        showOnOff: true,
                                        onToggle: (val) {
                                          setState(() {
                                            status = val;
                                          });
                                        },
                                      ),
                                    ),
                                    Container(
                                        margin:
                                            EdgeInsets.only(top: 20, left: 30),
                                        width: 150,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Color(0xff393a3e),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: Offset(0, 2),
                                            )
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 150,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    trigger(78, lamp2 ? 0 : 1);
                                                    lamp2 = !lamp2;                                                  });
                                                },
                                                child: lamp2 ? lampon : lampoff,
                                              ),
                                            ),
                                            Container(
                                                margin:
                                                    EdgeInsets.only(left: 15),
                                                child: Text(
                                                  "lamp 2",
                                                  style: TextStyle(
                                                    color: Color(0xff7b7b7f),
                                                    fontSize: 22,
                                                  ),
                                                )),
                                            Container(
                                                margin: EdgeInsets.only(
                                                    left: 15, top: 5),
                                                child: Text(
                                                  lamp2 ? "ON" : "OFF",
                                                  style: TextStyle(
                                                    color: lamp2
                                                        ? Color(0xffc8a871)
                                                        : Color(0xff7b7b7f),
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ))
                                          ],
                                        )),
                                    Container(
                                        margin:
                                            EdgeInsets.only(top: 20, left: 20),
                                        width: 150,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Color(0xff393a3e),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: Offset(0, 2),
                                            )
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 150,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    lamp4 = !lamp4;
                                                  });
                                                },
                                                child: lamp4 ? lampon : lampoff,
                                              ),
                                            ),
                                            Container(
                                                margin:
                                                    EdgeInsets.only(left: 15),
                                                child: Text(
                                                  "lamp 4",
                                                  style: TextStyle(
                                                    color: Color(0xff7b7b7f),
                                                    fontSize: 22,
                                                  ),
                                                )),
                                            Container(
                                                margin: EdgeInsets.only(
                                                    left: 15, top: 5),
                                                child: Text(
                                                  lamp4 ? "ON" : "OFF",
                                                  style: TextStyle(
                                                    color: lamp4
                                                        ? Color(0xffc8a871)
                                                        : Color(0xff7b7b7f),
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ))
                                          ],
                                        ))
                                  ],
                                ),
                              ],
                            ))
                          ],
                        )))
              ],
            )));
  }
}


class statspage extends StatefulWidget {
  @override
  _State createState() => _State();
  final List<Color> availableColors = [
    Colors.purpleAccent,
    Colors.yellow,
    Colors.lightBlue,
    Colors.orange,
    Colors.pink,
    Colors.redAccent,
  ];

}

class _State extends State<statspage> {
  final Duration timerDuration = Duration(seconds: 10,);
  bool selected = true;
  @override






  final Color barBackgroundColor = const Color(0xffcaac76);
  final Duration animDuration = const Duration(milliseconds: 250);

  int touchedIndex = -1;

  bool isPlaying = false;
  Widget build(BuildContext context) {
    Future<String> login() async {
      var url = Uri.parse('http://smart-home-server-mr-os7798-dev.apps.sandbox-m2.ll9k.p1.openshiftapps.com/api/authenticate');
      var response = await http.post(url,
          body: jsonEncode({'username': 'user', 'password': 'user'}),
          headers: {"content-type": "application/json"});
      return jsonDecode(response.body)['id_token'];
    }


    Future<String> getToken() async {
      if (token == null ) {
        token = await login();
      }
      return token;
    }


    Future<String> getBill() async {
      var url = Uri.parse(
          'http://smart-home-server-mr-os7798-dev.apps.sandbox-m2.ll9k.p1.openshiftapps.com/api/data/bill/');
      var token = await getToken();
      var response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + token,
        "content-type": "application/json"
      });
      return jsonDecode(response.body)['value'].toString();
    }


    FutureBuilder<String> getBillText(){

      return FutureBuilder(future: getBill(),builder: (context, snapshot) {
        if (snapshot.hasError)
          print(snapshot.error);
        return snapshot.hasData
            ? Text(snapshot.data,
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ))
            : Text("NA",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ));
      },);

    }

    Future<String> getKwh() async {
      var url = Uri.parse(
          'http://smart-home-server-mr-os7798-dev.apps.sandbox-m2.ll9k.p1.openshiftapps.com/api/data/kwh/');
      var token = await getToken();
      var response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + token,
        "content-type": "application/json"
      });
      return jsonDecode(response.body)['value'].toString();
    }


    FutureBuilder<String> getKwhText(){

      return FutureBuilder(future: getKwh(),builder: (context, snapshot) {
        if (snapshot.hasError)
          print(snapshot.error);
        return snapshot.hasData
            ? Text(snapshot.data,
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ))
            : Text("NA",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ));
      },);

    }


    Future<String> getKwhPrice() async {
      var url = Uri.parse(
          'http://smart-home-server-mr-os7798-dev.apps.sandbox-m2.ll9k.p1.openshiftapps.com/api/kwh/price/');
      var token = await getToken();
      var response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + token,
        "content-type": "application/json"
      });
      return jsonDecode(response.body)['value'].toString();
    }


    FutureBuilder<String> getKwhPriceText(){

      return FutureBuilder(future: getKwhPrice(),builder: (context, snapshot) {
        if (snapshot.hasError)
          print(snapshot.error);
        return snapshot.hasData
            ? Text(snapshot.data,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ))
            : Text("NA",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ));
      },);

    }


    Future<String> getPenaltyPrice() async {
      var url = Uri.parse(
          'http://smart-home-server-mr-os7798-dev.apps.sandbox-m2.ll9k.p1.openshiftapps.com/api/peak/price/');
      var token = await getToken();
      var response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + token,
        "content-type": "application/json"
      });
      return jsonDecode(response.body)['value'].toString();
    }


    FutureBuilder<String> getPenaltyPriceText(){

      return FutureBuilder(future: getPenaltyPrice(),builder: (context, snapshot) {
        if (snapshot.hasError)
          print(snapshot.error);
        return snapshot.hasData
            ? Text(snapshot.data,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ))
            : Text("NA",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ));
      },);

    }









    FutureBuilder bill = getBillText();
    FutureBuilder kwh = getKwhText();
    FutureBuilder kwh_price = getKwhPriceText();
    FutureBuilder penalty_price = getPenaltyPriceText();

    Timer _timer = new Timer.periodic(
        timerDuration,
            (Timer timer) =>
            setState(() {
              bill = getBillText();
              return bill;
            }));

    Timer kwh_timer = new Timer.periodic(
        timerDuration,
            (Timer timer) =>
            setState(() {
              bill = getKwhText();
              return kwh;
            }));


    Timer kwh_price_timer = new Timer.periodic(
        timerDuration,
            (Timer timer) =>
            setState(() {
              bill = getKwhPriceText();
              return kwh;
            }));



    Timer penalty_price_timer = new Timer.periodic(
        timerDuration,
            (Timer timer) =>
            setState(() {
              bill = getPenaltyPriceText();
              return kwh;
            }));

    return Scaffold(
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
          child: Container(
            color: Color(0xff282a2e),
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        colorFilter: new ColorFilter.mode(
                            Colors.black.withOpacity(0.5), BlendMode.dstATop),
                        image: AssetImage("assets/outside.jpg"),
                        fit: BoxFit.cover,
                      )),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: DecorationImage(
                              image: AssetImage("assets/user.jpg"),
                              fit: BoxFit.cover,
                            )),
                        width: 60,
                        height: 60,
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Text(
                            "Sepehr Samadi",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Text(
                            "Household",
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ))
                    ],
                  ),
                ),
                Container(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('Dashboard',
                              style: TextStyle(
                                color: Color(0xffffffff),
                              )),
                          leading: Icon(
                            Icons.dashboard,
                            color: Color(0xffcaac76),
                          ),
                          onTap: () {
                            // Update the state of the app
                            // ...
                            // Then close the drawer
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: Text(
                            'Living Room',
                            style: TextStyle(
                              color: Color(0xffffffff),
                            ),
                          ),
                          leading: Icon(
                            Icons.weekend_outlined,
                            color: Color(0xffcaac76),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => livingroom()),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            'Kitchen',
                            style: TextStyle(
                              color: Color(0xffffffff),
                            ),
                          ),
                          leading: Icon(
                            Icons.kitchen,
                            color: Color(0xffcaac76),
                          ),
                          onTap: () {
                            // Update the state of the app
                            // ...
                            // Then close the drawer
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: Text(
                            'Stats',
                            style: TextStyle(
                              color: Color(0xffffffff),
                            ),
                          ),
                          leading: Icon(
                            Icons.bar_chart,
                            color: Color(0xffcaac76),
                          ),
                          onTap: () {
                            // Update the state of the app
                            // ...
                            // Then close the drawer
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => livingroom()),
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            'Settings',
                            style: TextStyle(
                              color: Color(0xffffffff),
                            ),
                          ),
                          leading: Icon(
                            Icons.settings,
                            color: Color(0xffcaac76),
                          ),
                          onTap: () {
                            // Update the state of the app
                            // ...
                            // Then close the drawer
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ))
              ],
            ),
          )),
      appBar: AppBar(
        backgroundColor: Color(0xff282a2e),
        title: Center(
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(right: 10, left: 80),
                child: Icon(Icons.bar_chart),
              ),
              Container(
                child: Text(
                  "Stats",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 10, left: 80),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    image: DecorationImage(
                      image: AssetImage("assets/user.jpg"),
                      fit: BoxFit.cover,
                    )),
                width: 35,
                height: 35,
              ),
            ],
          ),
        ),
      ),
        body: Container(
        color: Color(0xff282a2e),
          child: Column(
            children: [
              Container(
                color: Color(0xff282a2e),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 180,
                          margin: EdgeInsets.only(top: 20, right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color(0xff393a3e),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.topLeft,
                                decoration: BoxDecoration(),
                                padding: EdgeInsets.only(top: 20, left: 10),
                                 child:
                                 Column(
                                   children: [
                                     Row(
                                       children: [
                                         FaIcon(
                                           FontAwesomeIcons.moneyBillWave,
                                           color: Color(0xffcaac76),
                                         ),
                                         Container(
                                             padding: EdgeInsets.only(left: 10),
                                             child: Text(
                                               "Bill",
                                               style: TextStyle(
                                                 color: Colors.white,
                                                 fontSize: 17,
                                                 fontStyle: FontStyle.italic,
                                               ),
                                             )
                                         )
                                       ],
                                     ),
                                     Container(
                                       margin: EdgeInsets.only(top: 25),
                                       child:
                                       Row(
                                         mainAxisAlignment: MainAxisAlignment.center,
                                         children: [
                                           Icon(
                                             Icons.monetization_on_outlined,
                                             color: Color(0xffcaac76),
                                           ),
                                           Icon(
                                             Icons.monetization_on_outlined,
                                             color: Color(0xffcaac76),
                                           ),
                                           Icon(
                                             Icons.monetization_on_outlined,
                                             color: Color(0xffcaac76),
                                           ),
                                           Icon(
                                             Icons.monetization_on_outlined,
                                             color: Color(0xffcaac76),
                                           ),
                                           Icon(
                                             Icons.monetization_on_outlined,
                                             color: Color(0xffcaac76),
                                           )
                                         ],
                                       ),
                                     ),
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.center,
                                       children: [
                                         Container(
                                             padding: EdgeInsets.only(top: 25),
                                             child: bill
                                         )
                                       ],
                                     ),
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.end,
                                       children: [
                                         Container(
                                             padding: EdgeInsets.only(top: 25, right: 10, bottom: 20),
                                             child: Text(
                                               "IRR",
                                               style: TextStyle(
                                                 color: Color(0xffcaac76),
                                                 fontSize: 23,
                                                 fontWeight: FontWeight.bold,
                                               ),
                                             )
                                         )
                                       ],
                                     ),
                                   ],
                                 )

                                ),

                            ],
                          )
                      ),
                      Container(
                          width: 180,
                          margin: EdgeInsets.only(top: 20, left: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color(0xff393a3e),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                  alignment: Alignment.topLeft,
                                  decoration: BoxDecoration(),
                                  padding: EdgeInsets.only(top: 20, left: 10),
                                  child:
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          FaIcon(
                                            FontAwesomeIcons.tachometerAlt,
                                            color: Color(0xffcaac76),
                                          ),
                                          Container(
                                              padding: EdgeInsets.only(left: 10),
                                              child: Text(
                                                "Consumption",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              )
                                          )
                                        ],
                                      ),
                                     Container(
                                       margin: EdgeInsets.only(top: 25),
                                       child:
                                       Row(
                                         mainAxisAlignment: MainAxisAlignment.center,
                                         children: [
                                           Icon(
                                             FontAwesomeIcons.bolt,
                                             color: Color(0xffcaac76),
                                           ),
                                           Icon(
                                             FontAwesomeIcons.bolt,
                                             color: Color(0xffcaac76),
                                           ),
                                           Icon(
                                             FontAwesomeIcons.bolt,
                                             color: Color(0xffcaac76),
                                           ),
                                           Icon(
                                             FontAwesomeIcons.bolt,
                                             color: Color(0xffcaac76),
                                           ),
                                           Icon(
                                             FontAwesomeIcons.bolt,
                                             color: Color(0xffcaac76),
                                           )
                                         ],
                                       ),
                                     ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              padding: EdgeInsets.only(top: 25),
                                              child: kwh,
                                          )
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Container(
                                              padding: EdgeInsets.only(top: 25, right: 10, bottom: 20),
                                              child: Text(
                                                "KWH",
                                                style: TextStyle(
                                                  color: Color(0xffcaac76),
                                                  fontSize: 23,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                          )
                                        ],
                                      ),
                                    ],
                                  )

                              ),

                            ],
                          )
                      ),
                    ],
                  ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    height: 250,
                    child:
                      AspectRatio(
                        aspectRatio: 1.6,
                        child:
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          color: const Color(0xff393a3e),
                          child: Stack(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      'Power Consumption',
                                      style: TextStyle(
                                          color: const Color(0xffffffff), fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      'This week history',
                                      style: TextStyle(
                                          color: const Color(0xffffffff), fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 38,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: BarChart(
                                          isPlaying ? randomData() : mainBarData(),
                                          swapAnimationDuration: animDuration,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                  )
                ],
              ),
              Row(
                children: [
                      Container(
                          margin: EdgeInsets.only(top: 10, left: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color(0xff393a3e),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                        child:
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 10, left: 10),
                                    child: Text("Base Costs",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 10, left: 10),
                                    child: Text("Without Penalties",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),),
                                  ),
                                    Container(
                                      margin: EdgeInsets.only(top: 20, left: 50),
                                      child:
                                      CircularPercentIndicator(
                                        radius: 80.0,
                                        lineWidth: 5.0,
                                        percent: 1,
                                        center: new Container(
                                            child: kwh_price,
                                        ),
                                        progressColor: Color(0xffcaac76),
                                      ),
                                    ),
                                  Container(
                                    margin: EdgeInsets.only(top: 10, left: 55, bottom: 10),
                                    child: Text("IRR",
                                      style: TextStyle(
                                        color: Color(0xffcaac76),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),),
                                  ),
                                ],
                              ),
                                Container(
                                  height: 200,
                                  margin: EdgeInsets.only(left: 40, right: 40, top: 5),
                                  child:
                                  DottedLine(
                                    dashLength: 10,
                                    dashGapLength: 10,
                                    lineThickness: 2,
                                    dashRadius: 16,
                                    direction: Axis.vertical,
                                    dashColor: Color(0xffffffff),
                                  ),
                                ),
                              
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 10, right: 10),
                                    child: Text("Additional Costs",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 10, right: 10),
                                    child: Text("Peak Time Usage Penalties",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 10, right: 50),
                                    child:
                                    CircularPercentIndicator(
                                      radius: 80.0,
                                      lineWidth: 5.0,
                                      percent: 1,
                                      center: new Container(
                                          child: penalty_price,
                                      ),
                                      progressColor: Color(0xffcaac76),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 10, right: 55, bottom: 10),
                                    child: Text("IRR",
                                      style: TextStyle(
                                        color: Color(0xffcaac76),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),),
                                  ),
                                ],
                              ),


                            ]

                          )
                      ),
                ],
              )
            ],
          ),
    )
    );
  }



  BarChartGroupData makeGroupData(
      int x,
      double y, {
        bool isTouched = false,
        Color barColor = Colors.white,
        double width = 22,
        List<int> showTooltips = const [],
      }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y + 1 : y,
          colors: isTouched ? [Colors.yellow] : [barColor],
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: 20,
            colors: [barBackgroundColor],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
    switch (i) {
      case 0:
        return makeGroupData(0, 5, isTouched: i == touchedIndex);
      case 1:
        return makeGroupData(1, 6.5, isTouched: i == touchedIndex);
      case 2:
        return makeGroupData(2, 5, isTouched: i == touchedIndex);
      case 3:
        return makeGroupData(3, 7.5, isTouched: i == touchedIndex);
      case 4:
        return makeGroupData(4, 9, isTouched: i == touchedIndex);
      case 5:
        return makeGroupData(5, 11.5, isTouched: i == touchedIndex);
      case 6:
        return makeGroupData(6, 6.5, isTouched: i == touchedIndex);
      default:
        return throw Error();
    }
  });



  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String weekDay;
              switch (group.x.toInt()) {
                case 0:
                  weekDay = 'Monday';
                  break;
                case 1:
                  weekDay = 'Tuesday';
                  break;
                case 2:
                  weekDay = 'Wednesday';
                  break;
                case 3:
                  weekDay = 'Thursday';
                  break;
                case 4:
                  weekDay = 'Friday';
                  break;
                case 5:
                  weekDay = 'Saturday';
                  break;
                case 6:
                  weekDay = 'Sunday';
                  break;
                default:
                  throw Error();
              }
              return BarTooltipItem(
                weekDay + '\n',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: (rod.y - 1).toString(),
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
        touchCallback: (barTouchResponse) {
          setState(() {
            if (barTouchResponse.spot != null &&
                barTouchResponse.touchInput is! PointerUpEvent &&
                barTouchResponse.touchInput is! PointerExitEvent) {
              touchedIndex = barTouchResponse.spot.touchedBarGroupIndex;
            } else {
              touchedIndex = -1;
            }
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) =>
          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          margin: 16,
          getTitles: (double value) {
            switch (value.toInt()) {
              case 0:
                return 'M';
              case 1:
                return 'T';
              case 2:
                return 'W';
              case 3:
                return 'T';
              case 4:
                return 'F';
              case 5:
                return 'S';
              case 6:
                return 'S';
              default:
                return '';
            }
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
    );
  }

  BarChartData randomData() {
    return BarChartData(
      barTouchData: BarTouchData(
        enabled: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) =>
          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          margin: 16,
          getTitles: (double value) {
            switch (value.toInt()) {
              case 0:
                return 'M';
              case 1:
                return 'T';
              case 2:
                return 'W';
              case 3:
                return 'T';
              case 4:
                return 'F';
              case 5:
                return 'S';
              case 6:
                return 'S';
              default:
                return '';
            }
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, Random().nextInt(15).toDouble() + 6,
                barColor: widget.availableColors[Random().nextInt(widget.availableColors.length)]);
          case 1:
            return makeGroupData(1, Random().nextInt(15).toDouble() + 6,
                barColor: widget.availableColors[Random().nextInt(widget.availableColors.length)]);
          case 2:
            return makeGroupData(2, Random().nextInt(15).toDouble() + 6,
                barColor: widget.availableColors[Random().nextInt(widget.availableColors.length)]);
          case 3:
            return makeGroupData(3, Random().nextInt(15).toDouble() + 6,
                barColor: widget.availableColors[Random().nextInt(widget.availableColors.length)]);
          case 4:
            return makeGroupData(4, Random().nextInt(15).toDouble() + 6,
                barColor: widget.availableColors[Random().nextInt(widget.availableColors.length)]);
          case 5:
            return makeGroupData(5, Random().nextInt(15).toDouble() + 6,
                barColor: widget.availableColors[Random().nextInt(widget.availableColors.length)]);
          case 6:
            return makeGroupData(6, Random().nextInt(15).toDouble() + 6,
                barColor: widget.availableColors[Random().nextInt(widget.availableColors.length)]);
          default:
            return throw Error();
        }
      }),
    );
  }

  Future<dynamic> refreshState() async {
    setState(() {});
    await Future<dynamic>.delayed(animDuration + const Duration(milliseconds: 50));
    if (isPlaying) {
      await refreshState();
    }
  }









}


class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({@required Color color, @required double radius})
      : _painter = _CirclePainter(color, radius);

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset =
        offset + Offset(cfg.size.width / 2, cfg.size.height - radius);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}

String percentageModifier(double value) {
  final roundedValue = value.ceil().toInt().toString();
  return '$roundedValue';
}
