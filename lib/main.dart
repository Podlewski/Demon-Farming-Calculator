import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

import 'dart:math';
import 'package:package_info/package_info.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demon Farming Calculator',
      
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Kalkulator farmy demonów'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _demons = 0;
  int _wastedHP = 0;
  int _wastedPitsPower = 0;
  int _wastedCreatures = 0;
  int _pitLords = 1;
  int _creatures = 1;
  int _hp = 3;
  int _missingCreatures = 0;

  void _countDemons() {
    
    int _maxFromPits;
    int _maxFromCreatures;

    bool _wastingHP = true;
    
    setState(() {
      _maxFromPits = (_pitLords * 50 / 35).floor();
      _maxFromCreatures = (_creatures * _hp / 35).floor();

      if(_maxFromCreatures > _creatures)
      {
        _wastingHP = false;
        _maxFromCreatures = _creatures; 

      }

      _demons = min(_maxFromPits, _maxFromCreatures);

      _wastedPitsPower = _maxFromPits - _demons;


      if(_wastingHP)
      {
        _wastedHP = (_creatures * _hp) - (_demons * 35);
        _wastedCreatures = (_wastedHP / _hp).floor();
      }
      else
      {
        _wastedCreatures = 0;
        _wastedHP = 0;
      }

      if(_wastedPitsPower != 0)
        _missingCreatures = ((35 - _wastedHP) / _hp).round();
      else
        _missingCreatures = 0;
    });
  }

  refreshPitLords(int pitLords) {
    setState(() { 
      _pitLords = pitLords;
      _countDemons();
    });
  }

  refreshCreatures(int creatures) {
    setState(() { 
      _creatures = creatures;
      _countDemons();
    });
  }

  refreshHP(int hp) {
    setState(() { 
      _hp = hp;
      _countDemons();
    });
  }

  @override
  Widget build(BuildContext context)
  {
    _countDemons();

    return new Scaffold(
      appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
              IconButton(
                icon: Icon(Icons.info),
                onPressed: () async {
                  PackageInfo packageInfo = await PackageInfo.fromPlatform();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: new Text(widget.title),
                        content: new Text(" Wersja " + packageInfo.version),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text("Zamknij"),
                            onPressed: () {Navigator.of(context).pop();},
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
          ]
        ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            new Container(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MyNumberPicker( notifyParent : refreshPitLords, text: "Liczba pit lordów", minValue: 1, maxValue: 30, ),
                  MyNumberPicker( notifyParent : refreshCreatures, text: "Liczba jednostek", minValue: 1, maxValue: 200, ),
                  MyNumberPicker( notifyParent : refreshHP, text: "Życie jednostki", minValue: 3, maxValue: 35, ),
                ],
              ),
            ),
            Text('Otrzymasz tyle demonów:'),
            Text('$_demons', style: Theme.of(context).textTheme.display1,),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: <Widget>[
                  Text('Marnujesz tyle jednostek:'),
                  Text('$_wastedCreatures', style: Theme.of(context).textTheme.display1,),
                ]),
                Column(children: <Widget>[
                  Text('Marnujesz tyle HP jednostek:'),
                  Text('$_wastedHP', style: Theme.of(context).textTheme.display1,),
                ]),
              ]
            ),
            SizedBox(height: 15),
            Text('Tylu jednostek brakuje do następnego demona:'),
            Text('$_missingCreatures', style: Theme.of(context).textTheme.display1,),
            SizedBox(height: 15),
            Text('Pit lordzi mogą stworzyć jeszcze tyle demonów:'),
            Text('$_wastedPitsPower', style: Theme.of(context).textTheme.display1,),
          ],
        ),
      ),
    );
  }
}

class MyNumberPicker extends StatefulWidget
{
  final Function(int) notifyParent;
  final String text;
  final int minValue;
  final int maxValue;
  
  MyNumberPicker({Key key, @required this.notifyParent, @required this.text, @required this.minValue, @required this.maxValue}) : super(key: key);

  @override
  _MyNumberPickerState createState() => _MyNumberPickerState(minValue);
}

class _MyNumberPickerState extends State<MyNumberPicker>
{
  int value;

  _MyNumberPickerState(this.value);

  @override
  Widget build(BuildContext context){
    return new Flexible(
      flex: 1,
      child: Padding(
        padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 10.0),
        child: Column(
          children: <Widget>[
            Text(widget.text + ":", style: TextStyle(fontSize: 15)),
            SizedBox(height: 10),
            new NumberPicker.integer(
                  initialValue: value,
                  minValue: widget.minValue,
                  maxValue: widget.maxValue,
                  onChanged: (newValue) => setState(() {
                    value = newValue;
                    widget.notifyParent(value);
                  })),
          ],
        ),
      )
    );
  }
}

