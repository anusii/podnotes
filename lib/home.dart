/// The home page for the app.
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
//
// Time-stamp: <Wednesday 2023-11-01 08:32:47 +1100 Graham Williams>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Graham Williams

library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:markdown_editor_plus/markdown_editor_plus.dart';
import 'package:podnotes/constants/app.dart';
import 'package:podnotes/constants/colours.dart';
import 'package:podnotes/constants/file_structure.dart';
import 'package:podnotes/constants/rest_api.dart';
import 'package:podnotes/constants/turtle_structures.dart';
import 'package:podnotes/nav_screen.dart';
import 'package:podnotes/widgets/err_dialogs.dart';
//import 'package:simple_markdown_editor/simple_markdown_editor.dart';

class Home extends StatefulWidget {
  final String webId;
  final Map authData;

  const Home({super.key, required this.webId, required this.authData});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TextEditingController? _textController;

  String text = "";

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.all(10),
            child: SplittedMarkdownFormField(
              controller: _textController,
              markdownSyntax: '## Headline',
              decoration: const InputDecoration(
                hintText: 'Editable text',
              ),
              emojiConvert: true,
            )),
        const SizedBox(
          height: 20,
        ),
        Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () async {
                  String noteText = _textController!.text;

                  // By default all notes will be encrypted before storing in
                  // a POD

                  // Get the master key
                  String masterKey = await secureStorage.read(
                        key: widget.webId,
                      ) ??
                      '';

                  // Hash plaintext master key to get hashed master key
                  String encKey = sha256
                      .convert(utf8.encode(masterKey))
                      .toString()
                      .substring(0, 32);

                  // Get date and time
                  String dateTimeStr = DateFormat("yyyyMMddTHHmmss")
                      .format(DateTime.now())
                      .toString();

                  // Create a random session key
                  final indKey = encrypt.Key.fromSecureRandom(32);

                  // Encrypt markdown text using random session key
                  final dataEncryptIv = encrypt.IV.fromLength(16);
                  final dataEncrypter = encrypt.Encrypter(
                      encrypt.AES(indKey, mode: encrypt.AESMode.cbc));
                  final dataEncryptVal =
                      dataEncrypter.encrypt(noteText, iv: dataEncryptIv);
                  String dataEncryptValStr = dataEncryptVal.base64.toString();

                  // Encrypt random key using the master key
                  final keyEncrypt = encrypt.Key.fromUtf8(encKey);
                  final keyEncryptIv = encrypt.IV.fromLength(16);
                  final keyEncryptEncrypter1 = encrypt.Encrypter(
                      encrypt.AES(keyEncrypt, mode: encrypt.AESMode.cbc));
                  final keyEncryptVal = keyEncryptEncrypter1
                      .encrypt(indKey.base64, iv: keyEncryptIv);
                  String keyEncryptValStr = keyEncryptVal.base64.toString();

                  // Create encrypted data ttl file body
                  String encNoteFileBody = genEncryptedNoteFileBody(
                      dateTimeStr, dataEncryptValStr, dataEncryptIv.base64);

                  // print(keyEncryptValStr);
                  // print('');
                  // print(encNoteFileBody);

                  // Create note file name
                  String noteFileName = '$noteFileNamePrefix$dateTimeStr.ttl';
                  String noteAclFileName = '$noteFileName.acl';

                  // Create ACL file body for the note file
                  String noteFileAclBody =
                      genPrvFileAclBody(noteAclFileName, widget.webId);

                  // Create ttl file to store encrypted note data on the POD
                  String createNoteFileRes = await createItem(
                      true,
                      noteFileName,
                      encNoteFileBody,
                      widget.webId,
                      widget.authData,
                      fileLoc: '$myNotesDirLoc/',
                      fileType: fileType[noteFileName.split('.').last],
                      aclFlag: false);

                  if (createNoteFileRes == 'ok') {
                    // Create acl file to store acl file data on the POD
                    String createAclFileRes = await createItem(
                        true,
                        noteAclFileName,
                        noteFileAclBody,
                        widget.webId,
                        widget.authData,
                        fileLoc: '$myNotesDirLoc/',
                        fileType: fileType[noteAclFileName.split('.').last],
                        aclFlag: true);

                    if (createAclFileRes == 'ok') {
                      // Store the encrypted session key on the POD
                      String updateIndKeyFileRes = await updateIndKeyFile(
                        widget.webId,
                        widget.authData,
                        noteFileName,
                        keyEncryptValStr,
                        '$myNotesDirLoc/$noteFileName',
                        keyEncryptIv.base64,
                      );

                      if (updateIndKeyFileRes == 'ok') {
                        // ignore: use_build_context_synchronously
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NavigationScreen(
                                    webId: widget.webId,
                                    authData: widget.authData,
                                    page: 'home',
                                  )),
                          (Route<dynamic> route) =>
                              false, // This predicate ensures all previous routes are removed
                        );
                      } else {
                        // ignore: use_build_context_synchronously
                        showErrDialog(context,
                            'Failed to update the individual key. Try again!');
                      }
                    } else {
                      // ignore: use_build_context_synchronously
                      showErrDialog(context,
                          'Failed to create the ACL resoruce. Try again!');
                    }
                  } else {
                    // ignore: use_build_context_synchronously
                    showErrDialog(context,
                        'Failed to store the note file in your POD. Try again!');
                  }

                  // Redirect to the home page
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: darkBlue,
                  backgroundColor: lightBlue, // foreground
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'SAVE NOTE',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        )
      ],
    );
    // Column(
    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //   children: [
    //     // const MarkdownAutoPreview(
    //     //   decoration: InputDecoration(
    //     //     hintText: 'Markdown Auto Preview',
    //     //   ),
    //     //   emojiConvert: true,
    //     //   // maxLines: 10,
    //     //   // minLines: 1,
    //     //   // expands: true,
    //     // ),
    //     SplittedMarkdownFormField(
    //       controller: _textController,
    //       markdownSyntax: '## Headline',
    //       decoration: const InputDecoration(
    //         hintText: 'Splitted Markdown FormField',
    //       ),
    //       emojiConvert: true,
    //     ),
    //   ],
    // );
    // Container(
    //   padding: const EdgeInsets.all(10),
    //   child: SafeArea(
    //     child: MarkdownAutoPreview(
    //       controller: _textController,
    //       enableToolBar: true,
    //       emojiConvert: true,
    //       // autoCloseAfterSelectEmoji: false,
    //       // onChanged: (String text) {
    //       //   setState(() {
    //       //     this.text = text;
    //       //   });
    //       // },
    //     ),
    //   ),
    // );
  }
}
