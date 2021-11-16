import 'package:flutter/material.dart';
import 'package:try1/utils.dart';
import 'custom_clipper.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class TimeTile {

  String first;
  String second;
  String third;
  TimeTile({ required this.first, required this.third ,required this.second });
}

List<TimeTile> history = [
  TimeTile(first: "From" ,
      second: "To",
      third:"Consumption")
];

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


  String first = "";
  bool disconnected = true;
  bool both = false;
  final databaseRef = FirebaseDatabase.instance.reference(); //database reference object

  addData(bool data) {
    databaseRef.update({'S1': data});
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
databaseRef.onValue.listen((event) {
  if(event.snapshot.value["S1"] == true ){
    both = true;
    first =  DateFormat('yyyy-MM-dd \n kk:mm:ss').format(DateTime.now()).toString();
    setState(() {
      disconnected = false;
    });
  }
  else if(event.snapshot.value["S1"] == false && both == true){
    both = false;
    history.add(TimeTile(first: first ,
        second: DateFormat('yyyy-MM-dd \n kk:mm:ss').format(DateTime.now()).toString(),
        third:event.snapshot.value["reading"]));
    setState(() {
      disconnected = true;
    });
  }
});

    /*Timer.periodic(Duration(seconds: 2), (timer) {
      fetch();
    });
*/
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
                  }
                  else {
                    addData(true);
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
                ),),title: Center(
                  child: Text(history[index].third,
                  style: TextStyle(
                    color: Colors.white
                  ),),
                )
                  ,trailing:Text(history[index].second,
                style: TextStyle(
                  color: Colors.white
                ),)  , );
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
          SizedBox(height: 50),
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
            Icon(
              Icons.tune,
              size: 26,
              color: Colors.white,
            ),
            SizedBox(width: 12),
            Text(
              'Menu',
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    ],
  );
}



