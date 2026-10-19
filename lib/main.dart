import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const BossApp());
}

class BossApp extends StatelessWidget {
  const BossApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Boss Live Football',
      theme: ThemeData(primarySwatch: Colors.green, scaffoldBackgroundColor: Colors.black),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List matches = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchScores();
  }

  fetchScores() async {
    try {
      final res = await http.get(Uri.parse('https://api.openligadb.de/getmatchdata/bl1/2023/1'));
      if (res.statusCode == 200) {
        setState(() {
          matches = jsonDecode(res.body);
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        matches = [
          {"Team1": {"TeamName": "Arsenal"}, "Team2": {"TeamName": "Man City"}, "MatchResults": [{"PointsTeam1": 2, "PointsTeam2": 1}]},
          {"Team1": {"TeamName": "Barca"}, "Team2": {"TeamName": "Real Madrid"}, "MatchResults": [{"PointsTeam1": 0, "PointsTeam2": 0}]},
        ];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BOSS LIVE FOOTBALL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: Colors.green[700], centerTitle: true),
      body: loading ? const Center(child: CircularProgressIndicator(color: Colors.green)) :
      ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(color: Colors.green[800], borderRadius: BorderRadius.circular(15)),
            child: const Center(child: Text('🔴 LIVE STREAMING\nTap a match below', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(height: 10),
          const Text('Live Scores', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ...matches.map((m) => Card(
            color: Colors.grey[900],
            child: ListTile(
              title: Text('${m['Team1']['TeamName']} vs ${m['Team2']['TeamName']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(m['MatchResults'] != null && m['MatchResults'].isNotEmpty ? '${m['MatchResults'][0]['PointsTeam1']} - ${m['MatchResults'][0]['PointsTeam2']}' : '0 - 0 Live', style: const TextStyle(color: Colors.green)),
              trailing: const Icon(Icons.play_circle, color: Colors.green, size: 35),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VideoScreen(title: '${m['Team1']['TeamName']} vs ${m['Team2']['TeamName']}'))),
            ),
          )).toList(),
          const SizedBox(height: 20),
          ElevatedButton.icon(onPressed: () => fetchScores(), icon: const Icon(Icons.refresh), label: const Text('Refresh Scores'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white)),
        ],
      ),
    );
  }
}

class VideoScreen extends StatefulWidget {
  final String title;
  const VideoScreen({super.key, required this.title});
  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.networkUrl(Uri.parse('https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8'));
    _videoController.initialize().then((_) {
      setState(() {
        _chewieController = ChewieController(videoPlayerController: _videoController, autoPlay: true, looping: false);
        initialized = true;
      });
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.green[700]),
      body: Center(child: initialized ? Chewie(controller: _chewieController!) : const CircularProgressIndicator(color: Colors.green)),
    );
  }
}
