import 'package:flutter/material.dart';
import 'package:podnotes/constants/colours.dart';

class NavDrawer extends StatelessWidget {
  String webId;
  Map authData;

  NavDrawer({Key? key, required this.webId, required this.authData})
      : super(key: key);

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
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
                Text(
                  name,
                  style: TextStyle(color: Colors.white, fontSize: 15),
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
                  onTap: () => {Navigator.of(context).pop()},
                ),
                ListTile(
                  leading: const Icon(Icons.border_color),
                  title: const Text('My Notes'),
                  onTap: () => {Navigator.of(context).pop()},
                ),
                ListTile(
                  leading: const Icon(Icons.share_rounded),
                  title: const Text('Note Sharing'),
                  onTap: () => {Navigator.of(context).pop()},
                ),
                ListTile(
                  leading: const Icon(Icons.file_open_outlined),
                  title: const Text('Shared Notes'),
                  onTap: () => {Navigator.of(context).pop()},
                ),
                const Divider(
                  color: titleAsh,
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () => {Navigator.of(context).pop()},
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Logout'),
                  onTap: () => {Navigator.of(context).pop()},
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
