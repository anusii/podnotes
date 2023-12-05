/// Individual's PODs app for diabetes care in Yarrabah.
///
/// Copyright (C) 2023 Software Innovation Institute, Australian National University
///
/// License: GNU General Public License, Version 3 (the "License")
/// https://www.gnu.org/licenses/gpl-3.0.en.html
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
/// Authors: Anushka Vidanage

import 'package:flutter/material.dart';
import 'package:podnotes/constants/colours.dart';
import 'package:podnotes/nav_drawer.dart';
import 'package:podnotes/nav_screen.dart';
import 'package:podnotes/widgets/data_cell.dart';
import 'package:podnotes/widgets/loading_animation.dart';

import 'package:solid_auth/solid_auth.dart';
import 'package:intl/intl.dart';

bool isNamePattern(String pattern) {
  // Check if the pattern contains the solid server url or profile card hashtag
  // We don't want to show suggestions for these cases.

  // if (SOLID_SERVER_URL.contains(pattern) ||
  //     '/profile/card#'.contains(pattern)) {
  //   return false;
  // }

  // Use a regular expression to check if pattern only contains
  // letters a-z or A-Z and dashes '-'.
  // This matches name-like patterns.

  RegExp regex = RegExp(r'^[a-zA-Z-]+$');
  return regex.hasMatch(pattern);
}

DataRow permissionRow(
    String permWebId,
    String permissionStr,
    Map authData,
    String resourceName,
    String userWebId,
    String currUrl,
    String resUser,
    BuildContext context) {
  String webIdCheck = userWebId.replaceAll('#me', '#');

  double c_width = MediaQuery.of(context).size.width * 0.35;
  return DataRow(cells: [
    DataCell(Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      width: c_width,
      child: Column(
        children: <Widget>[
          Text(
            resUser,
            style: const TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    )),
    dataCell(permissionStr),
    if (!permWebId.contains(webIdCheck)) ...[
      DataCell(
        IconButton(
          icon: const Icon(
            Icons.delete_outline,
            size: 24.0,
            color: Colors.red,
          ),
          onPressed: () {
            // showDialog(
            //     context: context,
            //     builder: (BuildContext ctx) {
            // return AlertDialog(
            //   title: const Text('Please Confirm'),
            //   content: const Text(
            //       'Are you sure you want to remove this permission?'),
            //   actions: [
            //     // The "Yes" button
            //     TextButton(
            //         onPressed: () async {
            //           // Loading animation
            //           showAnimationDialog(
            //             context,
            //             17,
            //             'Removing access!',
            //             false,
            //           );

            //           List delPermList = permissionStr.split(', ');
            //           String accessToken = authData['accessToken'];
            //           String permWebIdStr =
            //               permWebId.replaceAll('#', '#me');
            //           permWebIdStr = permWebIdStr.replaceAll('>', '');
            //           permWebIdStr = permWebIdStr.replaceAll('<', '');
            //           String delRes = await deletePermission(
            //               accessToken,
            //               authData,
            //               currUrl + resourceName,
            //               permWebId,
            //               delPermList);

            //           // If the file is encrypted and therefore a copy of the
            //           // encryption key is stored in recipient's POD
            //           // Delete that entry
            //           var rsaInfo = authData['rsaInfo'];
            //           var rsaKeyPair = rsaInfo['rsa'];
            //           var publicKeyJwk = rsaInfo['pubKeyJwk'];

            //           // Get the file content
            //           String dPopToken = genDpopToken(
            //               currUrl + resourceName,
            //               rsaKeyPair,
            //               publicKeyJwk,
            //               'GET');
            //           String encFileContent = await fetchPrvData(
            //               currUrl + resourceName, accessToken, dPopToken);
            //           bool encrypted_flag = false;
            //           Map prvDataMap = getFileContent(encFileContent);
            //           if (prvDataMap.containsKey('encryptVal')) {
            //             encrypted_flag = true;
            //           }

            //           // If the file is encrypted
            //           if (encrypted_flag) {
            //             List webIdContent = userWebId.split("/");
            //             String dirName = webIdContent[3];

            //             String remSharedRes = await removeSharedKey(
            //                 permWebIdStr,
            //                 dirName,
            //                 authData,
            //                 resourceName);
            //             //String remSharedRes = 'ok';

            //             if (remSharedRes != 'ok') {
            //               debugPrint('Could not delete shared key.');
            //             }
            //           }

            //           if (delRes == 'ok') {
            //             /// Update log files of the relevant PODs
            //             /// Here we need to update two log files
            //             /// File owner and permission recipient
            //             String accessListStr =
            //                 permissionStr.replaceAll(' ', '');
            //             String dateTimeStr = DateFormat("yyyyMMddTHHmmss")
            //                 .format(DateTime.now())
            //                 .toString();
            //             String logStr =
            //                 '${dateTimeStr};${currUrl}${resourceName};${userWebId};revoke;${userWebId};${permWebIdStr};${accessListStr.toLowerCase()}';

            //             // Write to log files of all actors in the permission
            //             // action
            //             String permLogUrlOwner = userWebId.replaceAll(
            //               'profile/card#me',
            //               PERM_LOG_FILE_LOC,
            //             );

            //             String permLogUrlReceiver =
            //                 permWebIdStr.replaceAll(
            //               'profile/card#me',
            //               PERM_LOG_FILE_LOC,
            //             );

            //             String permAppendRes1 = await addPermLogLine(
            //               permLogUrlOwner,
            //               authData,
            //               logStr,
            //               dateTimeStr,
            //             );

            //             String permAppendRes2 = await addPermLogLine(
            //               permLogUrlReceiver,
            //               authData,
            //               logStr,
            //               dateTimeStr,
            //             );

            //             if (permAppendRes1 != 'ok' ||
            //                 permAppendRes2 != 'ok') {
            //               debugPrint(
            //                   'Something went wrong with logging your permission!');
            //             }

            //             Navigator.pushReplacement(
            //               context,
            //               MaterialPageRoute(
            //                   builder: (context) => MainScreen(
            //                         authData: authData,
            //                         webId: userWebId,
            //                         page: 'setPermission',
            //                         selectSurveyIndex: 0,
            //                         currPath: currUrl,
            //                       )),
            //             );
            //           } else {
            //             debugPrint(
            //                 'Error occurred. Please try again in a while');
            //           }
            //         },
            //         child: const Text('Yes')),
            //     TextButton(
            //         onPressed: () {
            //           // Close the dialog
            //           Navigator.of(context).pop();
            //         },
            //         child: const Text('No'))
            //   ],
            // );
            //});
          },
        ),
      ),
    ] else ...[
      const DataCell(Text('')),
    ]
  ]);
}

// String webIdAutoFilledStr(String userName) {
//   return '$SOLID_SERVER_URL$userName/profile/card#';
// }

class ShareNote extends StatefulWidget {
  final Map authData; // Authentication data
  final String webId;
  final String currPath;
  final Map resInfo;

  const ShareNote({
    super.key,
    required this.authData,
    required this.webId,
    required this.currPath,
    required this.resInfo,
  });

  @override
  State<ShareNote> createState() => _ShareNoteState();
}

class _ShareNoteState extends State<ShareNote> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _permissionInputController = TextEditingController();

  // Loading widget

  @override
  Widget build(BuildContext context) {
    Map authData = widget.authData;
    String webId = widget.webId;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: lightGreen,
        centerTitle: true,
        title: const Text("POD Note Taker"),
      ),
      drawer: NavDrawer(
        webId: webId,
        authData: authData,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("File Access Permissions",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700)),
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  size: 27.0,
                                ),
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NavigationScreen(
                                              webId: webId,
                                              authData: authData,
                                              page: 'listNotes',
                                            )),
                                    (Route<dynamic> route) =>
                                        false, // This predicate ensures all previous routes are removed
                                  );
                                },
                              ),
                            ],
                          ),
                          const Divider(
                            color: Color.fromARGB(255, 160, 160, 160),
                            height: 10,
                            thickness: 1,
                            indent: 0,
                            endIndent: 10,
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Column(
                            children: [
                              const Text(
                                  '''You can add or remove access permission to your file here. In the following you can see the list of permissions that is already being given.''',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(
                                height: 20,
                              ),
                              resourceAttr(context, 'Resource name',
                                  widget.resInfo['resName']),
                              const SizedBox(
                                height: 5,
                              ),
                              resourceAttr(context, 'Resource type',
                                  widget.resInfo['resType']),
                            ],
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          DataTable(
                            columnSpacing: 20,
                            columns: const [
                              DataColumn(
                                  label: Expanded(
                                    child: Center(
                                      child: Text(
                                        'Pod name',
                                      ),
                                    ),
                                  ),
                                  tooltip:
                                      'Retrieved from access control lists'),
                              DataColumn(
                                  label: Expanded(
                                    child: Center(
                                      child: Text(
                                        'Permissions',
                                      ),
                                    ),
                                  ),
                                  tooltip:
                                      'Retrieved from access control lists'),
                              DataColumn(label: Text('')),
                              // DataColumn(label: Text('')),

                              ///necessary as the number of Column is same with the row
                            ],
                            rows: [
                              for (var resWebId
                                  in widget.resInfo['resPerm'].keys)
                                permissionRow(
                                    resWebId,
                                    widget.resInfo['resPerm'][resWebId],
                                    widget.authData,
                                    widget.resInfo['resName'],
                                    widget.webId,
                                    widget.currPath,
                                    widget.resInfo['resUsername'][resWebId],
                                    context),
                            ],
                            headingRowColor: MaterialStateProperty.resolveWith(
                                (states) => lightBlue),
                            headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                    onPressed: () async {
                                      String accessToken =
                                          widget.authData['accessToken'];
                                      String fileUrl = widget.currPath +
                                          widget.resInfo['resName'];
                                      _displayPermissionInputDialog(
                                          context,
                                          accessToken,
                                          fileUrl,
                                          widget.resInfo['resName'],
                                          widget.currPath);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: darkBlue, // background
                                        foregroundColor:
                                            lightBlue, // foreground
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 25),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    child: const Text(
                                      "Add New Permission",
                                      style: TextStyle(
                                        color: Colors.white,
                                        letterSpacing: 1.0,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                // TextButton(
                                //   child: Text('hello'),
                                //   onPressed: () {
                                //     var r = Random.secure();
                                //     print("random string");
                                //     print(randomAlphaNumeric(32,
                                //         provider: CoreRandomProvider.from(r)));
                                //   },
                                // ),
                              ])
                        ],
                      ),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  Row resourceAttr(BuildContext context, String labelStr, String valueStr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          '$labelStr:',
          style: const TextStyle(
            color: kTitleTextColor,
            letterSpacing: 2.0,

            fontWeight: FontWeight.bold,
            //fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: Text(
            valueStr,
            style: TextStyle(
              color: Colors.grey[800],
              letterSpacing: 2.0,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _displayPermissionInputDialog(
      BuildContext context,
      String accessToken,
      String resourceUrl,
      String resourceName,
      String currPath) async {
    List selectedItems = [];
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter the Web ID of the person'),
          content: const SizedBox(
            height: 280,
            child: Column(
              children: [
                // TypeAheadFormField(
                //   textFieldConfiguration: TextFieldConfiguration(
                //     controller: _permissionInputController,
                //     decoration: InputDecoration(hintText: "Web ID value"),
                //   ),
                //   suggestionsCallback: (inputPattern) async {
                //     // Textfield only gives suggestions when the
                //     // [inputPattern] satisfies the name-pattern.

                //     if (isNamePattern(inputPattern)) {
                //       return [webIdAutoFilledStr(inputPattern)];
                //     } else {
                //       return [];
                //     }
                //   },
                //   itemBuilder: (context, suggestion) {
                //     return ListTile(
                //       title: Text(suggestion),
                //     );
                //   },
                //   onSuggestionSelected: (suggestion) {
                //     // Set the text of the text field to the selected suggestion.

                //     _permissionInputController.text = suggestion;
                //   },
                //   noItemsFoundBuilder: (context) => Padding(
                //     padding: EdgeInsets.all(8.0),
                //     child: Text('No suggestions'),
                //   ),
                // ),
                //standardHeight(),
                // MultiSelectDialogField(
                //   items: permissionItems,
                //   title: Text("Select the permissions"),
                //   decoration: BoxDecoration(
                //     color: anuLightGold.withOpacity(0.15),
                //     borderRadius: BorderRadius.all(Radius.circular(40)),
                //     border: Border.all(
                //       color: anuGold,
                //       width: 2,
                //     ),
                //   ),
                //   buttonIcon: Icon(
                //     Icons.security,
                //     color: anuGold,
                //   ),
                //   buttonText: Text(
                //     "Select the permissions",
                //     style: TextStyle(
                //       color: anuGold,
                //       fontSize: 16,
                //     ),
                //   ),
                //   onConfirm: (values) {
                //     selectedItems = [];
                //     for (final value in values) {
                //       selectedItems.add(permMap[value]);
                //     }
                //   },
                // )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('ADD PERMISSION'),
              onPressed: () async {
                // await addPermission(
                //   context,
                //   _permissionInputController,
                //   accessToken,
                //   widget.authData,
                //   resourceName,
                //   resourceUrl,
                //   widget.currPath,
                //   selectedItems,
                //   widget.webId,
                // );
              },
            ),
          ],
        );
      },
    );
  }
}
