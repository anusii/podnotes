/// DESCRIPTION PLEASE
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
/// Authors: Anushka Vidanage, Graham Williams

library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:solid_auth/solid_auth.dart';

import 'package:notepod/common/rest_api/rest_api.dart';
import 'package:notepod/constants/file_structure.dart';
import 'package:notepod/constants/rdf_functions.dart';

/// TODO 20231220 gjw REQUIRES A DOC STRING.

// TODO 20231220 gjw IF THESE ARE CONSTANTS THEN SHOULDN'T THEY START WITH
// `CONST`?

String dividePubKeyStr(String keyStr) {
  final itemList = keyStr.split('\n');
  itemList.remove('-----BEGIN RSA PUBLIC KEY-----');
  itemList.remove('-----END RSA PUBLIC KEY-----');
  itemList.remove('-----BEGIN PUBLIC KEY-----');
  itemList.remove('-----END PUBLIC KEY-----');

  String keyStrTrimmed = itemList.join('');

  return keyStrTrimmed;
}

/// TODO 20231220 gjw REQUIRES A DOC STRING.

// TODO 20231220 gjw WHY USE TRIPPLE QUOTES HERE? CAN THEY BE REPLACED WITH A
// SINGLE QUOTE?

String genPubKeyStr(String keyStr) {
  return '''-----BEGIN RSA PUBLIC KEY-----\n$keyStr\n-----END RSA PUBLIC KEY-----''';
}

/// TODO 20231220 gjw REQUIRES A DOC STRING.

Future<bool> verifyEncKey(
  String plaintextEncKey,
  Map authData,
) async {
  String sha224Result =
      sha224.convert(utf8.encode(plaintextEncKey)).toString().substring(0, 32);

  var rsaInfo = authData['rsaInfo'];
  var rsaKeyPair = rsaInfo['rsa'];
  var publicKeyJwk = rsaInfo['pubKeyJwk'];

  String accessToken = authData['accessToken'];
  Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

  // Get webID.

  String webId = decodedToken['webid'];

  String encKeyFileUrl =
      webId.replaceAll('profile/card#me', '$encDirLoc/$encKeyFile');

  String dPopToken =
      genDpopToken(encKeyFileUrl, rsaKeyPair, publicKeyJwk, 'GET');

  String encKeyRes = await fetchPrvFile(encKeyFileUrl, accessToken, dPopToken);

  Map encFileContent = getFileContent(encKeyRes.toString());

  String encKeyHash = encFileContent['encKey'][1];

  return encKeyHash == sha224Result;
}
