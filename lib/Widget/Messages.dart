// import 'package:firebase_core/firebase_core.dart';
import 'dart:io';

import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:video_player/video_player.dart';
import '../Utils/global.dart';

class Messages extends StatefulWidget {
  String recieverId;
  Messages(this.recieverId);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  Future<bool> _getUser(id) async {
    final user = await FirebaseAuth.instance.currentUser;
    return user!.uid == id;
  }

  String extractPdfName(String firebaseUrl) {
    // print(firebaseUrl);
    try {
      // Split the URL by '/'
      List<String> urlParts = firebaseUrl.split('/');

      // Get the last part of the URL
      String lastPart = urlParts.last;

      // Decode the last part of the URL
      String decodedLastPart = Uri.decodeFull(lastPart);

      // Split the decoded last part by '%7B' and '%7D'
      List<String> nameParts =
          decodedLastPart.split("%7B").last.split("%7D").first.split(".");

      // Extract the PDF name
      String pdfName = nameParts.first;
      pdfName = pdfName.replaceAll("images/", "");
      // print(pdfName);
      return pdfName;
    } catch (e) {
      return "Document";
    }
  }

  bool _downloading = false;
  String _message = '';
  Future<void> _downloadPdf(link) async {
    setState(() {
      _downloading = true;
      _message = 'Downloading PDF...';
    });
    print('object');
    try {
      String url = link;
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;

      // Get the directory for the app's documents directory

      final file =
          File('/storage/emulated/0/Download/Chat_App/${extractPdfName(link)}');

      await file.writeAsBytes(bytes);
      print('object');
      setState(() {
        _message = 'PDF downloaded successfully!';
      });
    } catch (e) {
      setState(() {
        _message = 'Error downloading PDF: $e';
      });
    } finally {
      setState(() {
        _downloading = false;
      });
    }
  }

  void _launchDocumentURL(String url) async {
    print(await canLaunchUrl(Uri.parse(url)));

    await launchUrlString(
      url,
      mode: LaunchMode.inAppBrowserView,
    );
    // await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .doc(currentFirebaseUser!.uid)
            .collection(widget.recieverId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final user = FirebaseAuth.instance.currentUser;

          return ListView.builder(
            reverse: true,
            itemCount: snapshot.data?.docs.length,
            itemBuilder: ((context, index) => Column(
                  children: [
                    if (index == snapshot.data!.docs.length - 1)
                      DateChip(
                        date: (snapshot.data!.docs[index]['createdAt']
                                as Timestamp)
                            .toDate(),
                      ),
                    if (index < snapshot.data!.docs.length - 1 &&
                        ((snapshot.data!.docs[index]['createdAt'] as Timestamp)
                                    .toDate()
                                    .day !=
                                (snapshot.data!.docs[index + 1]['createdAt']
                                        as Timestamp)
                                    .toDate()
                                    .day ||
                            (snapshot.data!.docs[index]['createdAt']
                                        as Timestamp)
                                    .toDate()
                                    .month !=
                                (snapshot.data!.docs[index + 1]['createdAt']
                                        as Timestamp)
                                    .toDate()
                                    .month))
                      DateChip(
                        date: (snapshot.data!.docs[index]['createdAt']
                                as Timestamp)
                            .toDate(),
                      ),
                    snapshot.data!.docs[index]['videoLink'] == '' &&
                            snapshot.data!.docs[index]['fileLink'] == ''
                        ? BubbleSpecialOne(
                            color: user!.uid ==
                                    snapshot.data!.docs[index]['userId']
                                ? Colors.grey
                                : Color.fromARGB(255, 194, 166, 231),
                            text: snapshot.data!.docs[index]['text'],
                            isSender: user.uid ==
                                snapshot.data!.docs[index]['userId'],

                            // snapshot.data!.docs[index]['text'],
                            // user!.uid == snapshot.data!.docs[index]['userId'],

                            // snapshot.data!.docs[index]['userName'],
                            // // snapshot.data!.docs[index]['userImage'],
                            // KEY: ValueKey(snapshot.data!.docs[index].toString()),
                          )
                        : snapshot.data!.docs[index]['fileLink'] == ''
                            ? Align(
                                alignment: user?.uid ==
                                        snapshot.data!.docs[index]['userId']
                                    ? Alignment.topRight
                                    : Alignment.topLeft,
                                child: videoItemChat(
                                  videoLink: snapshot.data!.docs[index]
                                      ['videoLink'],
                                ),
                              )
                            : Align(
                                alignment: user?.uid ==
                                        snapshot.data!.docs[index]['userId']
                                    ? Alignment.topRight
                                    : Alignment.topLeft,
                                child: SizedBox(
                                  height: 15.h,
                                  width: 60.w,
                                  child: GestureDetector(
                                    onTap: () async {
                                      _launchDocumentURL(snapshot
                                          .data!.docs[index]['fileLink']);
                                    },
                                    child: Container(
                                      height: 60,
                                      width: 60.w,
                                      margin: EdgeInsets.all(10),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          border: Border.all(width: 2),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Row(children: [
                                        Icon(Icons.document_scanner),
                                        SizedBox(width: 5),
                                        SizedBox(
                                          width: 40.w,
                                          height: 30,
                                          child: Text(
                                            extractPdfName(snapshot
                                                .data!.docs[index]['fileLink']),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ),
                                ),
                              ),
                  ],
                )),
          );
        }));
  }
}

class videoItemChat extends StatefulWidget {
  String videoLink;
  videoItemChat({
    super.key,
    required this.videoLink,
  });

  @override
  State<videoItemChat> createState() => _videoItemChatState();
}

class _videoItemChatState extends State<videoItemChat> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    print(widget.videoLink);
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        'https://firebasestorage.googleapis.com/v0/b/chat-app-assignment-98835.appspot.com/o/storage%2FKI7L99e4d6S7w475M5T4UCeZQtV21000050164.mp4jpg?alt=media&token=727c6972-ecf0-4839-aafe-94349f58432c'));

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
    _controller.pause();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.h,
      width: 60.w,
      decoration: BoxDecoration(
        border: Border.all(width: 2),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      child: Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
              });
            },
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                VideoPlayer(_controller),
                // _ControlsOverlay(controller: _controller),
                VideoProgressIndicator(_controller, allowScrubbing: true),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                      }
                    });
                  },
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
