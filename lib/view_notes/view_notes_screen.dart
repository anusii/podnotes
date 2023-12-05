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
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:podnotes/constants/app.dart';
import 'package:podnotes/common/rest_api/rest_api.dart';
import 'package:podnotes/constants/file_structure.dart';
import 'package:podnotes/initial_setup/initial_setup_desktop.dart';
import 'package:podnotes/view_notes/view_notes.dart';
import 'package:podnotes/widgets/loading_screen.dart';

class ViewNotesScreen extends StatefulWidget {
  const ViewNotesScreen(
      {super.key, required this.authData, required this.webId});

  final Map authData;
  final String webId;

  @override
  State<ViewNotesScreen> createState() => _ViewNotesScreenState();
}

class _ViewNotesScreenState extends State<ViewNotesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static Future? _asyncDataFetch;

  @override
  void initState() {
    Map authData = widget.authData;
    String webId = widget.webId;
    String notesrUrl = webId.replaceAll(profCard, '$myNotesDirLoc/');
    _asyncDataFetch = getResourceList(
      authData,
      notesrUrl,
    );
    super.initState();
  }

  Widget _loadedScreen(List resourceList, String webId, Map authData) {
    List filesList = [];

    for (var i = 0; i < resourceList[1].length; i++) {
      String fileItem = resourceList[1][i];
      String fileDateStr = fileItem.split('-').last.replaceAll('.ttl', '');
      var fileDate = DateFormat('yyyy-MM-dd hh:mm:ssa')
          .format(DateTime.parse(fileDateStr));
      String fileName = '';
      if (fileItem.split('-').length == 3) {
        fileName = fileItem.split('-')[1].replaceAll('_', ' ');
      } else if (fileItem.split('-').length > 3) {
        var fileNameList =
            fileItem.split('-').getRange(1, fileItem.split('-').length - 1);
        fileName = fileNameList.join(' ').replaceAll('_', ' ');
      } else {
        throw Exception('Cannot happen!');
      }

      filesList.add([fileName, fileDate]);
    }

    return Container(
      color: Colors.white,
      child: ViewNotes(
        fileList: filesList,
        webId: webId,
        authData: authData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map authData = widget.authData;
    String webId = widget.webId;

    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: FutureBuilder(
            future: _asyncDataFetch,
            builder: (context, snapshot) {
              Widget returnVal;
              if (snapshot.connectionState == ConnectionState.done) {
                returnVal = _loadedScreen(
                  snapshot.data! as List,
                  webId,
                  authData,
                );
              } else {
                returnVal = loadingScreen(normalLoadingScreenHeight);
              }
              return returnVal;
            }),
      ),
    );
  }
}
