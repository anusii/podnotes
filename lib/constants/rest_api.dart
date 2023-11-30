/// DESCRIPTION
///
/// Copyright (C) 2023, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
//
// Time-stamp: <Wednesday 2023-11-01 08:26:39 +1100 Graham Williams>
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
/// Authors: AUTHORS

library;

import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:podnotes/constants/rdf_functions.dart';
import 'package:podnotes/constants/turtle_structures.dart';
import 'package:solid_auth/solid_auth.dart';

import 'package:podnotes/constants/file_structure.dart';

// import 'dart:async';

Future<List> initialStructureTest(Map authData) async {
  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];
  String accessToken = authData['accessToken'];
  Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

  // Get webID
  String webId = decodedToken['webid'];
  bool allExists = true;
  Map resNotExist = {
    'folders': [],
    'files': [],
    'folderNames': [],
    'fileNames': []
  };

  for (String containerName in folders) {
    String resourceUrl = webId.replaceAll('profile/card#me', '$containerName/');
    String dPopToken =
        genDpopToken(resourceUrl, rsaKeyPair, publicKeyJwk, 'GET');
    if (await checkResourceExists(resourceUrl, accessToken, dPopToken, false) ==
        'not-exist') {
      allExists = false;
      String resourceUrlStr =
          webId.replaceAll('profile/card#me', containerName);
      resNotExist['folders'].add(resourceUrlStr);
      resNotExist['folderNames'].add(containerName);
    }
  }

  for (var containerName in files.keys) {
    List fileNameList = files[containerName];
    for (String fileName in fileNameList) {
      String resourceUrl =
          webId.replaceAll('profile/card#me', '$containerName/$fileName');
      String dPopToken =
          genDpopToken(resourceUrl, rsaKeyPair, publicKeyJwk, 'GET');
      if (await checkResourceExists(
              resourceUrl, accessToken, dPopToken, false) ==
          'not-exist') {
        allExists = false;
        resNotExist['files'].add(resourceUrl);
        resNotExist['fileNames'].add(fileName);
      }
    }
  }

  return [allExists, resNotExist];
}

Future<String> checkResourceExists(
    String resUrl, String accessToken, String dPopToken, bool fileFlag) async {
  String contentType;
  String itemType;
  if (fileFlag) {
    contentType = '*/*';
    itemType = '<http://www.w3.org/ns/ldp#Resource>; rel="type"';
  } else {
    /// This is a directory (container)
    contentType = 'application/octet-stream';
    itemType = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"';
  }

  final response = await http.get(
    Uri.parse(resUrl),
    headers: <String, String>{
      'Content-Type': contentType,
      'Authorization': 'DPoP $accessToken',
      'Link': itemType,
      'DPoP': dPopToken,
    },
  );

  if (response.statusCode == 200 || response.statusCode == 204) {
    // If the server did return a 200 OK response,
    // then return true.
    return 'exist';
  } else if (response.statusCode == 404) {
    // If the server did not return a 200 OK response,
    // then return false.
    return 'not-exist';
  } else {
    return 'other-error';
  }
}

// Create a directory or a file
Future<String> createItem(
    bool fileFlag, String itemName, String itemBody, String webId, Map authData,
    {required String fileLoc, String? fileType, bool aclFlag = false}) async {
  String? itemLoc = '';
  String itemSlug = '';
  String itemType = '';
  String contentType = '';

  /*
  - fileFlag -> flag to identify whether the resouce is a file or a directory (eg: true/false)
  - itemName -> name of the creating resource (eg: logs (directory), permissions-log.ttl, permissions-log.ttl.acl)
  - itemBody -> body of the creating resource. String value
  - webId    -> webId of the POD owner
  - authData -> authentication data map
  - fileLoc  -> location of the file or directory (mynotes/newset (for a directory), mynotes/newset/ (for a file))
  - fileType -> type of the file (eg: text/html)
  - aclFlag  -> whether the file is an acl file or not (eg: true/false)
  */

  // Get authentication info
  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];
  String accessToken = authData['accessToken'];

  // Set up directory or file parameters
  if (fileFlag) {
    // This is a file (resource)
    itemLoc = fileLoc;
    itemSlug = itemName;
    contentType = fileType!;
    itemType = '<http://www.w3.org/ns/ldp#Resource>; rel="type"';
  } else {
    // This is a directory (container)
    itemLoc = fileLoc;
    itemSlug = itemName;
    contentType = 'application/octet-stream';
    itemType = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"';
  }

  String encDataUrl = webId.replaceAll('profile/card#me', itemLoc);
  String dPopToken = genDpopToken(encDataUrl, rsaKeyPair, publicKeyJwk, 'POST');

  final http.Response createResponse;

  if (aclFlag) {
    String aclFileUrl =
        webId.replaceAll('profile/card#me', '$itemLoc$itemName');
    String dPopToken =
        genDpopToken(aclFileUrl, rsaKeyPair, publicKeyJwk, 'PUT');

    // The PUT request will create the acl item in the server
    createResponse = await http.put(
      Uri.parse(aclFileUrl),
      headers: <String, String>{
        'Accept': '*/*',
        'Authorization': 'DPoP $accessToken',
        'Connection': 'keep-alive',
        'Content-Type': 'text/turtle',
        'Content-Length': itemBody.length.toString(),
        'DPoP': dPopToken,
      },
      body: itemBody,
    );
  } else {
    // The POST request will create the item in the server
    createResponse = await http.post(
      Uri.parse(encDataUrl),
      headers: <String, String>{
        'Accept': '*/*',
        'Authorization': 'DPoP $accessToken',
        'Connection': 'keep-alive',
        'Content-Type': contentType,
        'Link': itemType,
        'Slug': itemSlug,
        'DPoP': dPopToken,
      },
      body: itemBody,
    );
  }

  if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return 'ok';
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to create resource! Try again in a while.');
  }
}

Future<String> initialProfileUpdate(
  String profBody,
  Map authData,
  String webId,
) async {
  // Get authentication info
  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];
  String accessToken = authData['accessToken'];

  String profUrl = webId.replaceAll('#me', '');
  String dPopToken = genDpopToken(profUrl, rsaKeyPair, publicKeyJwk, 'PUT');

  // The PUT request will create the acl item in the server
  final updateResponse = await http.put(
    Uri.parse(profUrl),
    headers: <String, String>{
      'Accept': '*/*',
      'Authorization': 'DPoP $accessToken',
      'Connection': 'keep-alive',
      'Content-Type': 'text/turtle',
      'Content-Length': profBody.length.toString(),
      'DPoP': dPopToken,
    },
    body: profBody,
  );

  if (updateResponse.statusCode == 200 || updateResponse.statusCode == 205) {
    // If the server did return a 205 Reset response,
    return 'ok';
  } else {
    // If the server did not return a 205 response,
    // then throw an exception.
    throw Exception('Failed to update resource! Try again in a while.');
  }
}

Future<String> fetchPrvFile(
  String profCardUrl,
  String accessToken,
  String dPopToken,
) async {
  //return 'This is async function demo';
  final profResponse = await http.get(
    Uri.parse(profCardUrl),
    headers: <String, String>{
      'Accept': '*/*',
      'Authorization': 'DPoP $accessToken',
      'Connection': 'keep-alive',
      'DPoP': dPopToken,
    },
  );

  if (profResponse.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return profResponse.body;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    //print(profResponse.body);
    throw Exception('Failed to load profile data! Try again in a while.');
  }
}

Future<String> updateIndKeyFile(String webId, Map authData, String resName,
    String encSessionKey, String encNoteFilePath, String encNoteIv) async {
  String createUpdateRes = '';

  // Get indi key file url
  String keyFileUrl =
      webId.replaceAll('profile/card#me', '$encDirLoc/$indKeyFile');
  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];
  String accessToken = authData['accessToken'];

  // Update the file
  // First check if the file already contain the same value
  String dPopTokenKeyFile =
      genDpopToken(keyFileUrl, rsaKeyPair, publicKeyJwk, 'GET');
  String keyFileContent =
      await fetchPrvFile(keyFileUrl, accessToken, dPopTokenKeyFile);
  Map keyFileDataMap = getFileContent(keyFileContent);

  // Define query parameters
  String prefix1 = 'file: <$podnotesFile>';
  String prefix2 = 'terms: <$podnotesTerms>';

  String subject = 'file:$resName';
  String predObjPath = 'terms:$pathPred "$encNoteFilePath";';
  String predObjIv = 'terms:$ivPred "$encNoteIv";';
  String predObjKey = 'terms:$sessionKeyPred "$encSessionKey".';

  // Check if the resource is previously added or not
  if (keyFileDataMap.containsKey(resName)) {
    String existPath = keyFileDataMap[resName][pathPred];
    String existIv = keyFileDataMap[resName][ivPred];
    String existKey = keyFileDataMap[resName][sessionKeyPred];

    // If file does not contain the same encrypted value then delete and update
    // the file
    // NOTE: Public key encryption generates different hashes different time for same plaintext value
    // Therefore this always ends up deleting the previous and adding a new hash
    if (existKey != encSessionKey ||
        existPath != encNoteFilePath ||
        existIv != encNoteIv) {
      String predObjPathPrev = 'data:path "$existPath";';
      String predObjIvPrev = 'data:accessList "$existIv";';
      String predObjKeyPrev = 'data:sharedKey "$existKey".';

      // Generate update sparql query
      String query =
          'PREFIX $prefix1 PREFIX $prefix2 DELETE DATA {$subject $predObjPathPrev $predObjIvPrev $predObjKeyPrev}; INSERT DATA {$subject $predObjPath $predObjIv $predObjKey};';

      // Generate DPoP token
      String dPopTokenKeyFilePatch =
          genDpopToken(keyFileUrl, rsaKeyPair, publicKeyJwk, 'PATCH');

      // Run the query
      createUpdateRes = await sparqlUpdate(
          keyFileUrl, accessToken, dPopTokenKeyFilePatch, query);
    } else {
      // If the file contain same values, then no need to run anything
      createUpdateRes = 'ok';
    }
  } else {
    // Generate insert only sparql query
    String query =
        'PREFIX $prefix1 PREFIX $prefix2 INSERT DATA {$subject $predObjPath $predObjIv $predObjKey};';

    // Generate DPoP token
    String dPopTokenKeyFilePatch =
        genDpopToken(keyFileUrl, rsaKeyPair, publicKeyJwk, 'PATCH');

    // Run the query
    createUpdateRes = await sparqlUpdate(
        keyFileUrl, accessToken, dPopTokenKeyFilePatch, query);
  }

  if (createUpdateRes == 'ok') {
    return createUpdateRes;
  } else {
    throw Exception('Failed to create/update the shared file.');
  }
}

Future<String> sparqlUpdate(
  String profCardUrl,
  String accessToken,
  String dPopToken,
  String query,
) async {
  final editResponse = await http.patch(
    Uri.parse(profCardUrl),
    headers: <String, String>{
      'Accept': '*/*',
      'Authorization': 'DPoP $accessToken',
      'Connection': 'keep-alive',
      'Content-Type': 'application/sparql-update',
      'Content-Length': query.length.toString(),
      'DPoP': dPopToken,
    },
    body: query,
  );

  if (editResponse.statusCode == 200 || editResponse.statusCode == 205) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return 'ok';
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to write profile data! Try again in a while.');
  }
}
