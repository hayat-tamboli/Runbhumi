import 'dart:async';
import 'dart:ui';

import 'package:Runbhumi/services/services.dart';
import 'package:Runbhumi/utils/Constants.dart';
import 'package:Runbhumi/utils/theme_config.dart';
import 'package:Runbhumi/utils/validations.dart';
import 'package:Runbhumi/widget/customBackButton.dart';
import 'package:Runbhumi/widget/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

// status map

// 1 - public
// 2 - private
// 3 - closed

String userId = Constants.prefs.getString('userId');
String name = Constants.prefs.getString('name');

class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  GlobalKey<FormState> _addpostkey = GlobalKey<FormState>();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _datetime = new TextEditingController();
  TextEditingController _locationController = new TextEditingController();
  TextEditingController _descController = new TextEditingController();
  String _chosenSport;
  double _maxMembers = 2;
  int _type = 1;
  String _status = 'team';
  final PageController _addPostPageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    //sports
    final ThemeNotifier theme = Provider.of<ThemeNotifier>(context);
    var sportsList = DropdownButton(
      hint: Text("Sport"),
      elevation: 1,
      value: _chosenSport,
      items: [
        DropdownMenuItem(
          child: Text(
            "Basketball",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          value: "Basketball",
        ),
        DropdownMenuItem(
          child: Text(
            "Football",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          value: "Football",
        ),
        DropdownMenuItem(
            child: Text(
              "Volleyball",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            value: "Volleyball"),
        DropdownMenuItem(
            child: Text(
              "Cricket",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            value: "Cricket")
      ],
      onChanged: (value) {
        setState(
          () {
            print(value);
            _chosenSport = value;
          },
        );
      },
    );

    var slider = Slider(
      value: _maxMembers,
      onChanged: (newLimit) {
        setState(() => _maxMembers = newLimit);
      },
      min: 2,
      max: 50,
      label: _maxMembers.toInt().toString(),
      divisions: 48,
    );
    var publicRadio = RadioListTile(
      groupValue: _type,
      title: Text('Public'),
      value: 1,
      onChanged: (val) {
        setState(() => _type = val);
      },
    );
    var privateRadio = RadioListTile(
      groupValue: _type,
      title: Text('Private'),
      value: 2,
      onChanged: (val) {
        setState(() => _type = val);
      },
    );
    var teamRadio = RadioListTile(
      groupValue: _status,
      title: Text('Teams'),
      value: 'team',
      onChanged: (val) {
        setState(() => _status = val);
      },
    );
    var individualRadio = RadioListTile(
      groupValue: _status,
      title: Text('Individuals'),
      value: 'individual',
      onChanged: (val) {
        setState(() => _status = val);
      },
    );
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: CustomBackButton(),
        title: buildTitle(context, "Add Post"),
        actions: [
          IconButton(
              icon: Icon(Feather.info),
              onPressed: () {
                Navigator.pushNamed(context, "/cards");
                // showDialog(
                //   context: context,
                //   builder: (context) {
                //     return infoDialog(context);
                //   },
                // );
              })
        ],
      ),
      body: Container(
        child: PageView(
          controller: _addPostPageController,
          children: [
            Page1(
              theme: theme,
              addpostkey: _addpostkey,
              nameController: _nameController,
              sportsList: sportsList,
              datetime: _datetime,
              locationController: _locationController,
              descController: _descController,
              slider: slider,
              chosenSport: _chosenSport,
              maxMembers: _maxMembers,
              status: _status,
              type: _type,
              publicRadio: publicRadio,
              privateRadio: privateRadio,
              teamRadio: teamRadio,
              individualRadio: individualRadio,
            ),
            // MyPage2Widget(),
            // MyPage3Widget(),
          ],
        ),
      ),
    );
  }
}

class Page1 extends StatefulWidget {
  const Page1({
    Key key,
    @required GlobalKey<FormState> addpostkey,
    @required TextEditingController nameController,
    @required this.theme,
    @required this.sportsList,
    @required TextEditingController datetime,
    @required TextEditingController locationController,
    @required TextEditingController descController,
    @required this.slider,
    @required this.publicRadio,
    @required this.privateRadio,
    @required this.teamRadio,
    @required this.individualRadio,
    @required String chosenSport,
    @required double maxMembers,
    @required int type,
    @required String status,
  })  : _addpostkey = addpostkey,
        _nameController = nameController,
        _datetime = datetime,
        _locationController = locationController,
        _descController = descController,
        _chosenSport = chosenSport,
        _maxMembers = maxMembers,
        _status = status,
        _type = type,
        super(key: key);

  final GlobalKey<FormState> _addpostkey;
  final TextEditingController _nameController;
  final ThemeNotifier theme;
  final DropdownButton<String> sportsList;
  final TextEditingController _datetime;
  final TextEditingController _locationController;
  final TextEditingController _descController;
  final Slider slider;
  final RadioListTile publicRadio;
  final RadioListTile privateRadio;
  final RadioListTile teamRadio;
  final RadioListTile individualRadio;
  final String _chosenSport;
  final double _maxMembers;
  final int _type;
  final String _status;

  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  final db = FirebaseFirestore.instance;
  StreamSubscription sub;
  Map data;
  int userTokens = 0;
  @override
  void initState() {
    super.initState();
    sub = db
        .collection('users')
        .doc(Constants.prefs.getString('userId'))
        .snapshots()
        .listen((snap) {
      setState(() {
        data = snap.data();
        userTokens = data['eventTokens'];
      });
    });
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  SimpleDialog statusInfo(BuildContext context) {
    return SimpleDialog(
      title: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
                child: Icon(
              Feather.info,
              size: 64,
            )),
          ),
          Center(child: Text("What is a status")),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
              child: Text(
                  "Public: Anyone can join the event. Use this for events which needs to be filled fast" +
                      '\n' +
                      "Private: You will be notified when someone tries to join your event. You can then accept or decline.",
                  style: Theme.of(context).textTheme.subtitle1)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          decoration: BoxDecoration(
            // color: Theme.of(context).primaryColorLight,
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.72),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            // boxShadow: [
            // BoxShadow(color: Color(0x30000000),offset: Offset.fromDirection(1),blurRadius: 20)
            // ],
          ),
          child: SingleChildScrollView(
            child: Form(
              key: widget._addpostkey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "You have $userTokens event tokens left",
                      style: TextStyle(
                        color: userTokens > 0
                            ? Theme.of(context).textTheme.bodyText1.color
                            : Colors.red,
                      ),
                    ),
                  ),
                  InputBox(
                    controller: widget._nameController,
                    hintText: "Event name",
                    validateFunction: Validations.validateName,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.2,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Theme.of(context).inputDecorationTheme.fillColor,
                        border: Border.all(color: Color(0x00000000)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: widget.sportsList,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DateTimePicker(
                      controller: widget._datetime,
                    ),
                  ),
                  InputBox(
                    controller: widget._locationController,
                    hintText: "Borvalli, Mumbai, MH",
                    labelText: "Location",
                    validateFunction: Validations.validateName,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.2,
                      child: TextField(
                        controller: widget._descController,
                        // maxLengthEnforced: false,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: "Description",
                          hintText: "I want a 5v5 for...",
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //max member slider
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Select max members',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .backgroundColor
                                    .withOpacity(0.35),
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.start,
                            ),
                            Text(
                              widget._maxMembers.toInt().toString(),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .backgroundColor
                                    .withOpacity(0.55),
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ),
                      widget.slider,
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 4.0),
                        child: Row(
                          children: [
                            Text(
                              'Status',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .backgroundColor
                                    .withOpacity(0.35),
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.start,
                            ),
                            IconButton(
                                icon: Icon(Feather.info),
                                iconSize: 15.0,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return statusInfo(context);
                                    },
                                  );
                                })
                          ],
                        ),
                      ),
                      widget.publicRadio,
                      widget.privateRadio,
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 4.0),
                        child: Text(
                          'Who should join your Event',
                          style: TextStyle(
                            color: Theme.of(context)
                                .backgroundColor
                                .withOpacity(0.35),
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      widget.teamRadio,
                      widget.individualRadio,
                    ],
                  ),
                  Button(
                    myText: "Add Post",
                    myColor: userTokens > 0
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    onPressed: () {
                      // this funtion writes in the DB and adds an
                      // event when manually testing anything,
                      // just comment this function
                      if (widget._addpostkey.currentState.validate() &&
                          widget._descController.text != null &&
                          widget._datetime.text != null) {
                        if (userTokens > 0) {
                          createNewEvent(
                              widget._nameController.text,
                              userId,
                              name,
                              widget._locationController.text,
                              widget._chosenSport,
                              widget._descController.text,
                              [userId],
                              DateTime.parse(widget._datetime.text),
                              widget._maxMembers.toInt(),
                              widget._status,
                              widget._type,
                              false,
                              true);
                          // to show success dialog
                          showDialog(
                            context: context,
                            builder: (context) {
                              //wait for 3 sec
                              Future.delayed(Duration(seconds: 3), () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AnimatedBottomBar()));
                              });
                              return successDialog(context);
                            },
                          );
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return inValid(context);
                          },
                        );
                      }
                    },
                  ),
                  if (userTokens < 1)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Please contact us to purchase more tokens",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 72,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// List<Widget> addPostSliverAppBar(
//     BuildContext context, bool innerBoxIsScrolled) {
//   return <Widget>[
//     SliverAppBar(
//       expandedHeight: 250.0,
//       leading: CustomBackButton(),
//       elevation: 0,
//       floating: false,
//       pinned: true,
//       flexibleSpace: FlexibleSpaceBar(
//         centerTitle: true,
//         title: Container(
//             child: buildTitle(context, "Add Post"),
//             color: Theme.of(context).canvasColor.withOpacity(0.5)),
//         background: Image(
//           height: 200,
//           image: AssetImage('assets/addpostillustration.png'),
//         ),
//       ),
//     ),
//   ];
// }
SimpleDialog inValid(BuildContext context) {
  return SimpleDialog(
    title: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: Icon(
            Feather.info,
            size: 64,
          )),
        ),
        Center(child: Text("Invalid Input")),
      ],
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
            child: Text("The given input is invalid, please try again",
                style: Theme.of(context).textTheme.subtitle1)),
      ),
    ],
  );
}
