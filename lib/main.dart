import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import './views/downloadTiktok.dart';
import './views/downloadTiktokV2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.greenAccent,
        ),
      ),
      home: SosMediaScreen(),
    );
  }
}

class SosMediaScreen extends StatefulWidget {
  @override
  _SosMediaScreenState createState() => _SosMediaScreenState();
}

class _SosMediaScreenState extends State<SosMediaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text(
          'SOSMEDIA',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        elevation: 5,
      ),
      body: Column(
        children: [
          SizedBox(height: 30),
          Image.asset('lib/assets/img/logoHeader.png', height: 350),
          SizedBox(height: 10),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(borderRadius: BorderRadius.circular(25)),
              tabs: [
                Tab(
                  icon: Icon(Icons.settings, color: Colors.green),
                  text: 'Tools 1',
                ),
                Tab(
                  icon: Icon(Icons.settings, color: Colors.green),
                  text: 'Tools 2',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                toolsList([
                  {'name': 'TIKTOK Downloader V1', 'version': 1},
                  {'name': 'TIKTOK Downloader V2', 'version': 2},
                ], context),
                toolsList([
                  {'name': 'Coming Soon...', 'version': 0},
                ], context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget toolsList(List<Map<String, dynamic>> tools, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: tools.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: Icon(Icons.cloud_download, color: Colors.green),
              title: Text(
                tools[index]['name'],
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              subtitle:
                  tools[index]['name'] == 'Coming Soon...'
                      ? null
                      : Text(
                        "Support Video",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
              trailing: ElevatedButton(
                onPressed: () {
                  int version = tools[index]['version'];
                  if (version == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DownloadTiktok()),
                    );
                  } else if (version == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DownloadTiktokV2(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Coming Soon...')));
                  }
                },
                child: Text(
                  tools[index]['name'] == 'Coming Soon...'
                      ? 'Coming Soon'
                      : 'RUN',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
