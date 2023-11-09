/// Login screen for the app.
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
/// Authors: Anushka Vidanage

import 'package:flutter/material.dart';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:solid_auth/solid_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:podnotes/home.dart';
import 'package:podnotes/constants/app.dart';

class LoginScreen extends StatelessWidget {
  // Sample web ID to check the functionality
  var webIdController = TextEditingController()
    ..text = 'https://pods.solidcommunity.au';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
      decoration: screenWidth(context) < 1175
          ? const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/podnotes-background.jpg'),
                  fit: BoxFit.cover))
          : null,
      child: Row(
        children: [
          screenWidth(context) < 1175
              ? Container()
              : Expanded(
                  flex: 7,
                  child: Container(
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                                'assets/images/podnotes-background.jpg'),
                            fit: BoxFit.cover)),
                  )),
          Expanded(
              flex: 5,
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: screenWidth(context) < 1175
                        ? screenWidth(context) < 750
                            ? screenWidth(context) * 0.05
                            : screenWidth(context) * 0.25
                        : screenWidth(context) * 0.05),
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 5,
                    color: bgOffWhite,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Container(
                      height: 710,
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/images/podnotes.png",
                            width: 300,
                          ),
                          const SizedBox(
                            height: 0.0,
                          ),
                          const Divider(height: 15, thickness: 2),
                          const SizedBox(
                            height: 60.0,
                          ),
                          const Text('LOGIN WITH YOUR POD',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black,
                              )),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            controller: webIdController,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          createSolidLoginRow(context, webIdController),
                          const SizedBox(
                            height: 20.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    )));
  }

  // POD issuer registration page launch.

  launchIssuerReg(String issuerUri) async {
    // 20231110 gjw Currently on solidcommunity.au the register page is at
    // https://pods.solidcommunity.au/idp/register/.

    var url = '$issuerUri/idp/register';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  // Create login row for SOLID POD issuer

  Row createSolidLoginRow(
      BuildContext context, TextEditingController webIdTextController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
            child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(20),
            backgroundColor: exLightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () async => launchIssuerReg(
              (await getIssuer(webIdTextController.text)).toString()),
          child: const Text(
            'GET A POD',
            style: TextStyle(
              color: titleAsh,
              letterSpacing: 2.0,
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        )),
        const SizedBox(
          width: 15.0,
        ),
        Expanded(
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(20),
              backgroundColor: lightGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              // Get issuer URI
              String issuerUri = await getIssuer(webIdTextController.text);

              // Define scopes. Also possible scopes -> webid, email, api
              final List<String> scopes = <String>[
                'openid',
                'profile',
                'offline_access',
              ];

              // Authentication process for the POD issuer
              var authData =
                  // ignore: use_build_context_synchronously
                  await authenticate(Uri.parse(issuerUri), scopes, context);

              // Decode access token to get the correct webId
              String accessToken = authData['accessToken'];
              Map<String, dynamic> decodedToken =
                  JwtDecoder.decode(accessToken);
              String webId = decodedToken['webid'];

              // Navigate to the profile through main screen
              // ignore: use_build_context_synchronously
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Home(
                          webId: webId,
                          authData: authData,
                        )),
              );
            },
            child: const Text(
              'LOGIN',
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 2.0,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ],
    );
  }
}