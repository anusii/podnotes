import 'package:flutter/material.dart';
import 'package:podnotes/common/logout.dart';
import 'package:podnotes/constants/colours.dart';
import 'package:podnotes/login/screen.dart';
import 'package:podnotes/nav_screen.dart';

class NavDrawer extends StatelessWidget {
  final String webId;
  final Map authData;

  const NavDrawer({super.key, required this.webId, required this.authData});

  @override
  Widget build(BuildContext context) {
    String name = authData['name'];
    return Drawer(
      child: ListView(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
                top: 24 + MediaQuery.of(context).padding.top, bottom: 24),
            decoration: const BoxDecoration(
              color: darkGreen,
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 55,
                  backgroundImage: AssetImage('assets/images/avatar.png'),
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  name,
                  style: const TextStyle(color: backgroundWhite, fontSize: 25),
                ),
                Text(
                  name,
                  style: const TextStyle(color: backgroundWhite, fontSize: 15),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            child: Wrap(
              runSpacing: 10,
              children: [
                ListTile(
                  leading: const Icon(Icons.home_outlined),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NavigationScreen(
                                webId: webId,
                                authData: authData,
                                page: 'home',
                              )),
                      (Route<dynamic> route) =>
                          false, // This predicate ensures all previous routes are removed
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.border_color),
                  title: const Text('My Notes'),
                  onTap: () {
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
                // ListTile(
                //   leading: const Icon(Icons.share_rounded),
                //   title: const Text('Note Sharing'),
                //   onTap: () => {Navigator.of(context).pop()},
                // ),
                ListTile(
                  leading: const Icon(Icons.file_open_outlined),
                  title: const Text('Shared Notes'),
                  onTap: () 
                  {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NavigationScreen(
                                webId: webId,
                                authData: authData,
                                page: 'sharedNotes',
                              )),
                      (Route<dynamic> route) =>
                          false, // This predicate ensures all previous routes are removed
                    );
                  },
                ),
                const Divider(
                  color: titleAsh,
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Setup Encryption Key'),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NavigationScreen(
                                webId: webId,
                                authData: authData,
                                page: 'encKeyInput',
                              )),
                      (Route<dynamic> route) =>
                          false, // This predicate ensures all previous routes are removed
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Logout'),
                  onTap: () async {
                    if (await logoutUser(authData['logoutUrl'])) {
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    }
                  },
                ),
                const Divider(
                  color: titleAsh,
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  onTap: () => {},
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
