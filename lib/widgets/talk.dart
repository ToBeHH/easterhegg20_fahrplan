/*
congress_fahrplan
This is the dart file containing the Talk StatelessWidget.
SPDX-License-Identifier: GPL-2.0-only
Copyright (C) 2019 - 2021 Benjamin Schilling
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:timezone/timezone.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/room.dart';
import '../provider/favorite_provider.dart';

/// The Talk widget stores all data about it and build a card with all data relevant for it.
class Talk extends StatelessWidget {
  final String? code;
  final String? title;
  final String? track;
  final String? abstract;
  final DateTime? start;
  final String? startStr;
  final DateTime? end;
  final int? duration;
  final String? room;
  final List<Person>? speakers;
  bool? favorite;

  Talk(
      {this.code,
      this.title,
      this.track,
      this.abstract,
      this.start,
      this.startStr,
      this.end,
      this.duration,
      this.room,
      this.speakers,
      this.favorite});

  factory Talk.fromJson(
      var json, String timezone, List<Person> speakers, List<Room> rooms) {
    return Talk(
      code: json['code'] != null ? json['code'] : 0,
      title: json['title'] != null ? json['title'] : "",
      track: json['track'] != null ? json['track'] : "",
      abstract: json['abstract'] != null ? json['abstract'] : "",
      room: json['room'] != null
          ? rooms
              .firstWhere((element) => element.id == json['room'],
                  orElse: () => Room(id: 0, name: ''))
              .name
          : "",
      start: DateTime.parse(json['start']),
      startStr: DateFormat.Md().add_Hm().format(TZDateTime.from(
          DateTime.parse(json['start']), getLocation(timezone!))),
      end: DateTime.parse(json['end']),
      duration: DateTime.parse(json['end'])
          .difference(DateTime.parse(json['start']))
          .inMinutes,
      speakers: json['speakers'] != null
          ? jsonToSpeakerList(json['speakers'], speakers)
          : null,
      favorite: false,
    );
  }

  static List<Person> jsonToSpeakerList(var json, List<Person> speakers) {
    List<Person> persons = [];
    for (var code in json) {
      for (var s in speakers) {
        if (s.code == code) {
          persons.add(s);
          break;
        }
      }
    }
    return persons;
  }

  @override
  build(BuildContext context) {
    return Card(
      child: Semantics(
        child: ListTile(
          title: Semantics(
              label: 'Talk title, $title',
              child: ExcludeSemantics(child: Text(title!))),
          subtitle: getCardSubtitle(),
          leading: Ink(
            child: Consumer<FavoriteProvider>(
              builder: (context, favoriteProvider, child) => IconButton(
                tooltip: "Add talk $title to favorites.",
                icon: Icon(
                  favorite! ? Icons.favorite : Icons.favorite_border,
                ),
                onPressed: () {
                  DateTime day =
                      DateTime(start!.year, start!.month, start!.day);
                  favoriteProvider.favoriteTalk(this, day);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: favorite == true
                        ? Text('\"$title\" added to favorites.')
                        : Text('\"$title\" removed from favorites.'),
                    action: SnackBarAction(
                      label: "Revert",
                      onPressed: () => favoriteProvider.favoriteTalk(this, day),
                    ),
                    duration: Duration(seconds: 3),
                  ));
                },
              ),
            ),
          ),
          trailing: Ink(
            decoration: ShapeDecoration(
              shape: CircleBorder(),
            ),
            child: IconButton(
              tooltip: "Show talk $title details.",
              icon: Icon(
                Icons.info,
                color: Colors.white,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => SimpleDialog(
                    contentPadding: EdgeInsets.all(10),
                    title: Text('$title'),
                    children: <Widget>[
                      BlockSemantics(
                        child: Column(
                          children: getDetails(),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Semantics(
                            label: 'Copy abstract.',
                            child: IconButton(
                              icon: Icon(Icons.content_copy),
                              tooltip: 'Copy abstract.',
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: abstract));
                              },
                            ),
                          ),
                          Semantics(
                            label: 'Open $title',
                            child: ExcludeSemantics(
                              child: IconButton(
                                tooltip: 'Open talk.',
                                icon: Icon(
                                  Icons.open_in_browser,
                                ),
                                onPressed: () => openBrowser(
                                    'https://cfp.eh20.easterhegg.eu/eh20/talk/$code'),
                              ),
                            ),
                          ),
                          Semantics(
                            label: 'Share $title',
                            child: ExcludeSemantics(
                              child: IconButton(
                                tooltip: 'Share talk.',
                                icon: Icon(
                                  Icons.share,
                                ),
                                onPressed: () => Share.share(
                                    'Check out this talk: https://cfp.eh20.easterhegg.eu/eh20/talk/$code'),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  openBrowser(String url) {
    Uri uri = Uri.parse(url);
    launchUrl(uri); // async, but we don't care
  }

  Semantics getCardSubtitle() {
    String textString = '';
    textString = textString +
        ('$startStr' != ''
            ? ('$room' != '' ? '$startStr' + ' - ' : '$startStr')
            : ' - ');
    textString = textString +
        ('$room' != '' ? ('$track' != '' ? '$room' + ' - ' : '$room') : ' - ');
    textString = textString + ('$track' != '' ? '$track' : ' - ');
    return Semantics(
        label: 'Start $startStr, Room $room, Track $track',
        child: ExcludeSemantics(child: Text(textString)));
  }

  List<Widget> getDetails() {
    List<Widget> widgets = [];

    /// Add the start details
    if (startStr != '') {
      widgets.add(
        Semantics(
          label: 'Start $startStr',
          child: ExcludeSemantics(
            child: Row(
              children: <Widget>[
                Container(
                  child: Icon(Icons.access_time),
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                ),
                Text(
                  '$startStr',
                ),
              ],
            ),
          ),
        ),
      );
    }

    /// Add the duration details
    if (end != '') {
      widgets.add(
        Semantics(
          label: 'Duration $duration minutes',
          child: ExcludeSemantics(
            child: Row(
              children: <Widget>[
                Container(
                  child: Icon(Icons.hourglass_empty),
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                ),
                Text(
                  '$duration minutes',
                ),
              ],
            ),
          ),
        ),
      );
    }

    /// Add the room details
    if (room != '') {
      widgets.add(
        Semantics(
          label: 'Room $room',
          child: ExcludeSemantics(
            child: Row(
              children: <Widget>[
                Container(
                  child: Icon(Icons.room),
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                ),
                Text(
                  '$room',
                ),
              ],
            ),
          ),
        ),
      );
    }

    /// Add the track details
    if (track != '') {
      widgets.add(
        Semantics(
          label: 'Track $track',
          child: ExcludeSemantics(
            child: Row(
              children: <Widget>[
                Container(
                  child: Icon(Icons.school),
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                ),
                Text(
                  '$track',
                ),
              ],
            ),
          ),
        ),
      );
    }

    /// Add the persons details
    if (speakers!.length > 0) {
      for (Person p in speakers!) {
        widgets.add(Semantics(
          label: 'Presenter ${p.name}',
          child: ExcludeSemantics(
            child: Row(
              children: <Widget>[
                Container(
                  child: Icon(Icons.group),
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                ),
                Text(p.name!.length > 20
                    ? '${p.name!.substring(0, 19)}...'
                    : '${p.name}'),
              ],
            ),
          ),
        ));
      }
    }

    /// Add the abstract text
    if (abstract != '') {
      widgets.add(
        Semantics(
          label: 'Abstract $abstract',
          child: ExcludeSemantics(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Abstract: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('$abstract'),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }
}

class Person {
  String? code;
  String? name;
  String? avatar;

  Person({this.code, this.name, this.avatar});

  factory Person.fromJson(var json) {
    return Person(
      code: json['code'] != null ? '${json['code']}' : '',
      name: json['name'] != null ? json['name'] : '',
      avatar: json['avatar'] != null ? json['avatar'] : '',
    );
  }
}
