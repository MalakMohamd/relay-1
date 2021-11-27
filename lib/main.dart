import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:try1/utils.dart';
import 'custom_clipper.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';


class TimeTile {

  String first;
  String second;
  TimeTile({ required this.first, required this.second });
}

List<TimeTile> history = [];

void main() => runApp(MyApp());



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

 
  // Notification System 
  // Local Notification Object

  late FlutterLocalNotificationsPlugin localNotification;


  String first = "";
  bool disconnected = true;
  bool both = false;
  final databaseRef = FirebaseDatabase.instance.reference().child("project-1-fda8c-default-rtdb"); //database reference object

  addData(bool data) {
    databaseRef.set({'S1': data});
  }

  void fetch() {
    databaseRef.once().then((DataSnapshot snapshot)  {
      // disconnected = snapshot.value["S1"];
      setState(() {

      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

// android settings initialiizer 
     var androidIntialize = new AndroidInitializationSettings("ic_launcher");

     // IOS settings Initializer

     var iOSIntialize = new IOSInitializationSettings();
     //Initilization Settings

     var initialzationSettings = new InitializationSettings(
       android: androidIntialize , iOS: iOSIntialize
     );

     // setting up local notification

     localNotification = new FlutterLocalNotificationsPlugin();
     localNotification.initialize(initialzationSettings);

databaseRef.onValue.listen((event) {
  if(event.snapshot.value["S1"] == true){

    // calling the notification function

    _shownotification();

    both = true;
    first =  DateFormat('yyyy-MM-dd \n kk:mm:ss').format(DateTime.now()).toString();

  }
  else if(event.snapshot.value["S1"] == false && both == true){
    history.add(TimeTile(first: first , second: DateFormat('yyyy-MM-dd \n kk:mm:ss').format(DateTime.now()).toString()));
    setState(() {});
  }
});

    /*Timer.periodic(Duration(seconds: 2), (timer) {
      fetch();
    });
*/
  }

  // Notification function
 Future _shownotification() async {
    var androidDetails = new AndroidNotificationDetails("channelId", "Notifier", importance: Importance.high);

    var iosDetails = new IOSNotificationDetails();

    var generalNotificationDetails = new NotificationDetails(android : androidDetails , iOS: iosDetails);
    

    await localNotification.show(0 , "Connected to alternative source", "body", generalNotificationDetails);

  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: bgColor,
        body: ListView(
          children: <Widget>[
            Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                upperCurvedContainer(context),

              ],
            ),
            AvatarGlow(
              glowColor: disconnected ? Colors.grey : Color.fromRGBO(37, 112, 252, 1),
              endRadius: 100.0,
              duration: Duration(milliseconds: 2000),
              repeat: true,
              showTwoGlows: true,
              repeatPauseDuration: Duration(milliseconds: 100),
              shape: BoxShape.circle,
              child: InkWell(
                splashColor: Colors.transparent,
                onTap: () {
                  if (disconnected == false) {
                    addData(false);
                    setState(() {
                      disconnected = true;
                    });
                  }
                  else {
                    addData(true);
                    setState(() {
                      disconnected = false;
                    });
                  }
                  /*
                  setState(() {
                    if (disconnected == true) {
                      disconnected = false;
                    }
                    else {
                      disconnected = true;
                    }
                  });*/
                },
                child: Material(
                  elevation: 2,
                  shape: CircleBorder(
                  ),
                  color: disconnected? Colors.grey : Color.fromRGBO(37, 112, 252, 1),
                  child: SizedBox(
                    height: 150,
                    width: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.power_settings_new,
                          color: Colors.white,
                          size: 50,
                        ),
                        SizedBox(height: 10),
                        Text(
                          disconnected? "Disconnected" : "Connected",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.10),
            ListView.builder(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (listViewContext, index){
                return ListTile(leading: Text(history[index].first,
                style: TextStyle(
                  color: Colors.white
                ),), trailing:Text(history[index].second,
                style: TextStyle(
                  color: Colors.white
                ),)  ,);
              },
              itemCount:history.length ,
            )
        /*StreamBuilder(
          stream: databaseRef.onValue,
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasData) {
              databaseRef.once().then((DataSnapshot snapshot)  {
                // disconnected = snapshot.value["S1"];
                if(snapshot.value["S1"] == true){
                  print(snapshot.value);
                }
                setState(() {
                  disconnected = S1 ;
                });
              });
              return Text("$snapshot");
            }
            else if (snapshot.hasError) {
              return Text("Error");
            }
            else {
              return Text("DATA");
            }
          })*/],
        ));
  }
}

Widget upperCurvedContainer(BuildContext context) {
  return ClipPath(
    clipper: MyCustomClipper(),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      height: 320,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: curveGradient,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _topRow(),
          SizedBox(height: 20),
          Text('Project Name', style: vpnStyle),
        ],
      ),
    ),
  );
}

Widget _topRow() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        height: 50,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(width: 12),
            Text(
              'Text here',
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
      Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            Icons.tune,
            size: 26,
            color: Colors.white,
          ),
        ),
      )
    ],
  );
}



