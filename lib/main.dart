import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_admob/firebase_admob.dart';

const String testDevice = '80B4A19147066E6CE182BDF9C33EAEB0';

void main() {
  runApp(MaterialApp(
    home: NinjaCard(),
  ));
}
class NinjaCard extends StatefulWidget {
  @override
  _NinjaCardState createState() => _NinjaCardState();
}
class _NinjaCardState extends State<NinjaCard> {
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    nonPersonalizedAds: true,
    keywords: <String>['Game','Gaming','Arcade','Fun','India','Bored','Entertainment','Book'],
  );

  //percentage correct stats

  int prevNum = 0;
  int curNum = 50;
  double score = 0;
  var bal = '100.00';
  String sProfit = '';
  Color profCol = Colors.green;
  String newCurNum = '50';
  int bet = 0;
  RewardedVideoAd videoAd = RewardedVideoAd.instance;
  BannerAd _bannerAd;
  BannerAd createBannerAd(){
    return BannerAd(
        adUnitId: 'ca-app-pub-2273073266916535/8125139781',
        size: AdSize.banner,
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event){
          print("BannerAd $event");
        }
    );
  }
  @override
  void initState()  {
    _increaseBalance(.1);
    FirebaseAdMob.instance.initialize(
      appId: 'ca-app-pub-2273073266916535~1751303128',
    );
    _bannerAd = createBannerAd()..load()..show();
    videoAd.listener = (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      print('REWARDED VIDEO AD $event');
      if(event == RewardedVideoAdEvent.rewarded){
        setState(() {
          _increaseBalance(rewardAmount.roundToDouble());
          profCol = Colors.green;
          sProfit = '+100.00';
        });
      }
    };
    videoAd.load(
      adUnitId: 'ca-app-pub-2273073266916535/3563912399',
      targetingInfo: targetingInfo,
    );
    super.initState();
  }
  @override
  void dispose(){
    _bannerAd.dispose();
    super.dispose();
  }
  Future<double> _getNumFromSharedPref() async{
    final prefs = await SharedPreferences.getInstance();
    final startupNumber = prefs.getDouble('startupNumber');
    if(startupNumber == null){
      return 99.9;
    }
    else {
      return startupNumber;
    }
  }
  Future<void> _increaseBalance(double amount) async{
    final prefs = await SharedPreferences.getInstance();
    double prevBal = await _getNumFromSharedPref();
    double newBal = prevBal + amount;
    await prefs.setDouble('startupNumber', newBal);
    setState(() {
      score = newBal;
      bal = newBal.toStringAsFixed(2);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Icon(
                      Icons.local_atm,
                    color: Colors.green,
                    size: 30,
                  ),
                  ),
                ),
                TextSpan(
                    text:'$bal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
       leading: GestureDetector(
         onTap: (){
           videoAd.show();
         },
         child: Icon(
           Icons.add_circle_outline,
           color: Colors.yellow,
         ),
       ),
        centerTitle: true,
        backgroundColor: Colors.black, //Colors.white10,
      ),
      body: Container(
      decoration: BoxDecoration(
      gradient: LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
      Color(0xFF3383CD),
      Color(0xFF11249F),
      ],
      ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 100.0,
              height: 100.0,
              child: FloatingActionButton(
                onPressed: () {
                  if(score < 0.01){
                    videoAd.load(
                      adUnitId: 'ca-app-pub-2273073266916535/3563912399',
                      targetingInfo: targetingInfo,
                    );
                    videoAd.show();
                  }
                  else {
                    double setBet = score/5;
                    var randNum = new Random();
                    int iNum = randNum.nextInt(100);
                    String sNum = iNum.toString();
                    if (iNum < 10) {
                      sNum = '0' + '$sNum';
                    }
                    setState(() {
                      if (int.parse(newCurNum) < int.parse(sNum)) {
                        int x = int.parse(newCurNum);
                        if(x == 0){
                          x = 1;
                        }
                        double dif = setBet*(x/50.0);
                        _increaseBalance(dif);
                        profCol = Colors.green;
                        sProfit = '+' + dif.toStringAsFixed(2);
                      }
                      if (int.parse(newCurNum) > int.parse(sNum)) {
                        _increaseBalance(setBet *(-1.00));
                        profCol = Colors.red;
                        String temp = setBet.toStringAsFixed(2);
                        sProfit = '-$temp';
                      }
                      if(int.parse(newCurNum) == int.parse(sNum)){
                        profCol = Colors.white;
                        sProfit = '+0.00';
                      }
                      prevNum = int.parse(newCurNum);
                      newCurNum = sNum;
                    });
                  }
                  },
                child: Text(
                  'Over',
                  style: TextStyle(
                    fontSize: 25.0,
                  ),
                ),
                backgroundColor: Colors.green,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 5,
                ),
                Container(
                  width: 80,
                  child: Text(
                    '$prevNum',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: 180,
                  child: Text(
                    '$newCurNum',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 90.0,
                    ),
                  ),
                ),
                Container(
                    width: 80.0,
                  child: Text(
                    '$sProfit',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: profCol,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: 5,
                ),
              ],
            ),
            SizedBox(
              width: 100.0,
              height: 100.0,
              child: FloatingActionButton(
                onPressed: () {
                  if(score < 0.01){
                    videoAd.load(
                      adUnitId: 'ca-app-pub-2273073266916535/3563912399',
                      targetingInfo: targetingInfo,
                    );
                    videoAd.show();
                  }
                  else {
                    double setBet = score/5;
                    var randNum = new Random();
                    int iNum = randNum.nextInt(100);
                    String sNum = iNum.toString();
                    if (iNum < 10) {
                      sNum = '0' + '$sNum';
                    }
                    setState(() {
                      if (int.parse(newCurNum) > int.parse(sNum)) {
                        int x = int.parse(newCurNum);
                        if(x == 100){
                          x = 99;
                        }
                        double dif = setBet*((100-x)/50.00);
                        _increaseBalance(dif);
                        profCol = Colors.green;
                        sProfit = '+' + dif.toStringAsFixed(2);
                      }
                      if (int.parse(newCurNum) < int.parse(sNum)) {
                        _increaseBalance(setBet*(-1.00));
                        profCol = Colors.red;
                        String temp = setBet.toStringAsFixed(2);
                        sProfit = '-$temp';
                      }
                      if(int.parse(newCurNum) == int.parse(sNum)){
                        profCol = Colors.white;
                        sProfit = '+0.00';
                      }
                      prevNum = int.parse(newCurNum);
                      newCurNum = sNum;
                    });
                  }
                },
                child: Text(
                  'Under',
                  style: TextStyle(
                    fontSize: 25.0,
                  ),
                ),
                backgroundColor: Colors.red,
              ),
            ),

            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
      ),
    );
  }
}

