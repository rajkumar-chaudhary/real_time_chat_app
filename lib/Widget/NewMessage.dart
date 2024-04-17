import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/Utils/global.dart';
import 'package:image_picker/image_picker.dart';

class NewMessages extends StatefulWidget {
  String recieverId;
  String recieverName;
  String name;
  NewMessages(this.recieverId, this.recieverName, this.name);

  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  String _enteredMessage = '';
  String videoLink = '';
  String fileLink = '';

  bool _isLoading = false;

  var _controller = new TextEditingController();

  void _SendMessage() async {
    print(fileLink);
    FocusScope.of(context).unfocus();
    _controller.clear();
    if (videoLink != '') {
      _enteredMessage = 'Video';
    }
    if (fileLink != '') {
      _enteredMessage = 'Document';
    }
    await FirebaseFirestore.instance
        .collection("chat")
        .doc(currentFirebaseUser!.uid)
        .collection(widget.recieverId)
        .add({
      'fileLink': fileLink,
      'videoLink': videoLink,
      'text': _enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': currentFirebaseUser!.uid,
      'userName': widget.recieverName,
    });
    await FirebaseFirestore.instance
        .collection("chat")
        .doc(widget.recieverId)
        .collection(currentFirebaseUser!.uid)
        .add({
      'fileLink': fileLink,
      'videoLink': videoLink,
      'text': _enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': currentFirebaseUser!.uid,
      'userName': widget.name,
    });

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentFirebaseUser!.uid)
        .collection('recentChat')
        .doc(widget.recieverId)
        .set({
      'fileLink': fileLink,
      'videoLink': videoLink,
      'ID': widget.recieverId,
      'Name': widget.recieverName,
      'lastText': _enteredMessage,
      'createdAt': Timestamp.now(),
    });
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.recieverId)
        .collection('recentChat')
        .doc(currentFirebaseUser!.uid)
        .set({
      'fileLink': fileLink,
      'videoLink': videoLink,
      'ID': currentFirebaseUser!.uid,
      'Name': widget.name,
      'lastText': _enteredMessage,
      'createdAt': DateTime.now(),
    });
    _enteredMessage = '';
    videoLink = '';
    fileLink = '';
  }

  Future<String> uploadImagesFunction(image) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('storage')
        .child(currentFirebaseUser!.uid + image.name + 'jpg');

    await ref.putFile(File(image.path)).whenComplete(() => null);

    final url = await ref.getDownloadURL();

    return url;
  }

  Future<String> uploadFilesFunction(file) async {
    // print(file.path.split('/').last);
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('storage')
        .child(currentFirebaseUser!.uid + file.path.split('/').last);

    await ref.putFile(File(file.path)).whenComplete(() => null);

    final url = await ref.getDownloadURL();
    print(url);

    return url;
    // return "";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 1,
          color: Colors.grey,
        ),
      ),
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.only(left: 5),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Message'),
              onChanged: (value) {
                setState(() {
                  _enteredMessage = value;
                });
              },
            ),
          ),
          //button to pick document
          _isLoading == true
              ? CircularProgressIndicator()
              : Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.attach_file),
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          var _selectedFile;
                          print('file1');
                          try {
                            // Open the file picker and allow the user to pick one file
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
                            );
                            print('file2');

                            if (result != null) {
                              setState(() {
                                _selectedFile = File(result.files.single.path!);
                              });
                              print('file3 :${_selectedFile!.path}');
                            }

                            fileLink = await uploadFilesFunction(_selectedFile);
                            _SendMessage();
                          } catch (e) {
                            print('Error picking file: $e');
                          }
                          setState(() {
                            _isLoading = false;
                          });
                        }),
                    // IconButton(
                    //     onPressed: () async {
                    //       XFile? _pickedImage;

                    //       final picker = ImagePicker();
                    //       final pickedImage = await picker.pickImage(
                    //         source: ImageSource.camera,
                    //         imageQuality: 50,
                    //         maxWidth: 150,
                    //       );
                    //       setState(() {
                    //         _pickedImage = pickedImage;
                    //       });
                    //       videoLink = await uploadImagesFunction(pickedImage);
                    //       _SendMessage();
                    //     },
                    //     icon: Icon(Icons.photo)),
                    IconButton(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          XFile? _pickedImage;

                          final picker = ImagePicker();
                          final pickedImage = await picker.pickVideo(
                            source: ImageSource.gallery,
                          );
                          setState(() {
                            _pickedImage = pickedImage;
                          });
                          videoLink = await uploadImagesFunction(pickedImage);
                          print(videoLink);
                          _SendMessage();
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        icon: Icon(Icons.videocam_sharp)),
                    IconButton(
                      onPressed:
                          _enteredMessage.trim().isEmpty ? null : _SendMessage,
                      icon: Icon(Icons.send),
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                )
        ],
      ),
    );
  }
}
