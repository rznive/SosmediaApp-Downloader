import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/getService.dart';

class DownloadTiktok extends StatefulWidget {
  @override
  _DownloadTiktokV1State createState() => _DownloadTiktokV1State();
}

class _DownloadTiktokV1State extends State<DownloadTiktok> {
  TextEditingController urlController = TextEditingController();
  bool isLoading = false;
  Map<String, dynamic>? resultData;
  bool _permissionChecked = false;

  @override
  void initState() {
    super.initState();
    if (!_permissionChecked) {
      requestStoragePermission();
    }
  }

  Future<void> requestStoragePermission() async {
    if (Platform.isAndroid) {
      var managePermission = await Permission.manageExternalStorage.request();
      if (!managePermission.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Permission to manage storage not granted")),
        );
      }
    }

    setState(() {
      _permissionChecked = true;
    });
  }

  void _submitUrl() async {
    String enteredUrl = urlController.text.trim();

    if (enteredUrl.isEmpty || !enteredUrl.startsWith("http")) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Invalid URL format")));
      return;
    }

    setState(() {
      isLoading = true;
      resultData = null;
    });

    var response = await ApiService.fetchTikTokData(enteredUrl, "v1");

    setState(() {
      isLoading = false;
      if (response != null && response.containsKey('error')) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response['error'])));
      } else {
        resultData = response;
      }
    });
  }

  Future<void> _downloadFile(String url, String filename) async {
    String downloadDir = "/storage/emulated/0/Download";

    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: downloadDir,
      fileName: filename,
      showNotification: true,
      openFileFromNotification: true,
    );

    if (taskId != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Download started")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to start download")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text("TikTok Downloader V1", style: GoogleFonts.poppins()),
        backgroundColor: Colors.green[700],
        elevation: 10,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: TextField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: "Paste TikTok URL",
                  hintText:
                      "e.g., https://www.tiktok.com/@user/video/1234567890",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                  ),
                ),
                keyboardType: TextInputType.url,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: ElevatedButton(
                onPressed: _submitUrl,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                  backgroundColor: Color(0xFF4CAF50),
                  shadowColor: Colors.greenAccent,
                ),
                child: Text(
                  "Download Video",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(color: Colors.green[700]),
              ),
            if (resultData != null) buildResultSection(resultData!),
          ],
        ),
      ),
    );
  }

  Widget buildResultSection(Map<String, dynamic> data) {
    if (data.containsKey("error")) {
      return Text(data["error"], style: TextStyle(color: Colors.red));
    }

    var account = data["account"];
    var media = data["media"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(account["profileImg"] ?? ""),
                radius: 40,
                backgroundColor: Colors.grey[200],
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account["nickname"] ?? "No Name",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "@${account["username"]}",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            media["videoCover"] ?? '',
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _downloadFile(
                        media["videoNoWatermark"] ?? "",
                        "${account["nickname"]}_${account["videoId"]}.mp4",
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                      backgroundColor: Color(0xFF388E3C),
                      shadowColor: Colors.greenAccent,
                    ),
                    child: Text(
                      "Download Video",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _downloadFile(
                        media["videoMusic"] ?? "",
                        "${account["nickname"]}_${account["videoId"]}.mp3",
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                      backgroundColor: Colors.blue,
                      shadowColor: Colors.blueAccent,
                    ),
                    child: Text(
                      "Download MP3",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
