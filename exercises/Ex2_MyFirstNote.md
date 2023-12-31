# Exercise 2: My First Note

**Table of Contents**

- [Login](#login)
- [Make a note](#make_note)


This exercise will show you how to create a note in the Podnotes web app.

Note: If you have flutter installed, you could also build and run the app locally on your machine.


## Login<a name="login"></a>

Open the Podnotes app ([web app](https://Podnotes.solidcommunity.au/)) and click `Login`.

**Option 1: no recent login**

If you have not logged in recently, you will probably see a login window, enter the email address and password that you used to create your POD.

![POD login](../assets/images/server_login_popup.png)

This will open an `Login` popup and asking you to enter your POD account email and password. Enter your `Email` and `Password`, and click `Login`. `Authorize` the Podnotes app to login to your POD.

This will then show a popup window with heading `An application is requesting access`, showing your webID and asking you to `Authorize` the Podnotes app to login to your POD. Click `Authorize`.

![POD authorization](../assets/images/server_pod_auth_popup.png)

**Option 2: recent login with same webID**

In this case, you will see a popup with heading `An application is requesting access`, showing your last used webID and asking you to `Authorize` the Podnotes app to login to your POD. Click `Authorize`.

**Option 3: recent login with different webID**

If you have multiple webIDs and wish to use a different webID than that shown in the `An application is requesting access` popup, scroll down and select `Use a different account`, enter your credentials for your preferred webID, and click `Authorize`.

**Wait**

Be patient, *you may need to wait several seconds for login* process to complete.




## Make a note<a name="make_note"></a>

By default, the Podnotes app opens on the create new note page, or you can get to this page by selecting `Home` in the menu.

In `Note Title`` field, enter a title for your note.

Below the Note Title field, enter the text of your note using markdown.

![New Note](../assets/images/new_note_empty.png)


As you write you will see the rendered html is shown on the right hand side.


![Note in Progress](../assets/images/new_note_draft.png)

Click `Save` button to save your note. (Note: the app is not auto saving in the background, although that can be implemented in flutter).

After saving, you wil see an empty new note page.

Open the menu and click `My Notes` to view your saved notes.

![Menu](../assets/images/podnotes_menu.png)

Congratulations, you have successfully saved your first note in a POD!

![My Notes list](../assets/images/my_notes_list.png)

You can open your note, by clicking on your note in the list.

![Opened saved note](../assets/images/opening_saved_note.png)
