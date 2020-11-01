import 'dart:async';

import 'package:flutter/material.dart';
import 'musique.dart';
import 'package:audioplayer/audioplayer.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coda Music',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Coda Music'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
 List<Musique> maListDeMusiques = [
   new Musique('Theme Swift', 'Lewis Capardi', 'images/someOneYouLoved.jpg', 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'),
   new Musique('Theme Solo', 'Lewis Bobo', 'images/someOneYouLoved.jpg', 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3')
 ];
 AudioPlayer audioPlayer;
 Musique maMusiqueActuelle;
 StreamSubscription positionSub;
 StreamSubscription stateSub;
 Duration Position = new Duration(seconds: 0);
 Duration duree = new Duration(seconds: 10);
 PlayerState statut = PlayerState.stopped;
 int index = 0;
 @override
 void initState() {
    super.initState();
    maMusiqueActuelle = maListDeMusiques[index]; //premiere musique
   configurationAudioPlayer();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.grey[600],
        elevation: 10.0,
      ),
      backgroundColor: Colors.grey[400],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Card(
              elevation: 3.0,
              child: new Container(
                width: MediaQuery.of(context).size.height/2.5,
                height: 250.0,
                child: new Image.asset(maMusiqueActuelle.imagePath, fit: BoxFit.cover,),
              ),
            ),
            textAvecStyle(maMusiqueActuelle.titre, 1.5),
            textAvecStyle(maMusiqueActuelle.artiste, 1.0),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                bouton(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                bouton((statut == PlayerState.playing)? Icons.pause: Icons.play_arrow, 45.0, (statut == PlayerState.playing)?ActionMusic.pause: ActionMusic.play),
                bouton(Icons.fast_forward, 30.0, ActionMusic.forward),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget> [
                textAvecStyle(fromDuration(Position), 0.8),
                textAvecStyle(fromDuration(duree), 0.8),
              ],
            ),
            new Slider(value: Position.inSeconds.toDouble(),
                min: 0.0,
                max: 30.0,
                inactiveColor: Colors.white,
                activeColor: Colors.red,
                onChanged: (double d){
                  setState(() {
                    Duration nouvelDuration = new Duration(seconds: d.toInt());
                    Position = nouvelDuration;
                  });
                })
          ],
        ),
      ),
    );
  }
  IconButton bouton (IconData icone, double taille, ActionMusic action){
   return new IconButton(
     color: Colors.white,
     iconSize: taille,
     icon: new Icon(icone),
     onPressed: (){
       switch(action){
         case ActionMusic.play:
           play();
           break;
         case ActionMusic.pause:
           pause();
           break;
         case ActionMusic.rewind:
           rewind();
           break;
         case ActionMusic.forward:
           forward();
           break;
       }
     },
   );
  }
  Text textAvecStyle(String data, double scale){
   return new Text(
     data,
     textScaleFactor: scale,
     textAlign: TextAlign.center,
     style: new TextStyle(
       fontSize: 20.0,
       fontStyle: FontStyle.italic,
     )
   );

  }
  void configurationAudioPlayer(){
    audioPlayer = new AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged.listen((pos) => setState(()=> Position = pos));
    stateSub = audioPlayer.onPlayerStateChanged.listen((state) {
      if(state == AudioPlayerState.PLAYING){
        setState(() {
          duree = audioPlayer.duration;
        });
      }else if(state == AudioPlayerState.STOPPED){
        setState(() {
          statut = PlayerState.stopped;
        });
      }
    }, onError: (message){
      print('erreur: $message');
      setState(() {
        statut = PlayerState.stopped;
        duree = new Duration(seconds: 0);
        Position = new Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await  audioPlayer.play(maMusiqueActuelle.urlSong);
  setState(() {
    statut = PlayerState.playing;
  });
 }
 Future pause() async {
   await  audioPlayer.pause();
   setState(() {
     statut = PlayerState.paused;
   });
 }
 void forward(){
   if (index == maListDeMusiques.length - 1){
     index = 0;
   }else{
     index++;
   }
   maMusiqueActuelle = maListDeMusiques[index];
   audioPlayer.stop();
   play();
 }
 void rewind(){
   if (Position > Duration(seconds: 3)){
     audioPlayer.seek(0.0); //recommence la chansson
   }else{
     if(index == 0){
       index = maListDeMusiques.length - 1;
     }else{
       index--;
     }
     maMusiqueActuelle = maListDeMusiques[index];
     audioPlayer.stop();
     configurationAudioPlayer();
     play();
   }
   maMusiqueActuelle = maListDeMusiques[index];
   audioPlayer.stop();
   play();
 }
 String fromDuration(Duration duree){
   return duree.toString().split('.').first;
 }
}

enum ActionMusic {
  play,
  pause,
  rewind,
  forward
}
enum PlayerState {
  playing,
  stopped,
  paused
}
