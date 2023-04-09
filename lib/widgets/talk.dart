/*
congress_fahrplan
This is the dart file containing the Talk StatelessWidget.
SPDX-License-Identifier: GPL-2.0-only
Copyright (C) 2019 - 2021 Benjamin Schilling
*/

import 'package:alarm/alarm.dart';
import 'package:easterhegg20_fahrplan/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:timezone/timezone.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n.dart';
import '../model/room.dart';
import '../provider/favorite_provider.dart';

/// The Talk widget stores all data about it and build a card with all data relevant for it.
class Talk extends StatefulWidget {
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
  bool? alarm;

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
      this.favorite,
      this.alarm});

  @override
  State<Talk> createState() => _TalkState();

  factory Talk.fromJson(var json, String dateFormat, String timezone,
      List<Person> speakers, List<Room> rooms) {
    var location = getLocation(timezone);
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
      startStr: DateFormat(dateFormat)
          .format(TZDateTime.from(DateTime.parse(json['start']), location)),
      end: DateTime.parse(json['end']),
      duration: DateTime.parse(json['end'])
          .difference(DateTime.parse(json['start']))
          .inMinutes,
      speakers: json['speakers'] != null
          ? jsonToSpeakerList(json['speakers'], speakers)
          : null,
      favorite: false,
      alarm: false,
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
}

class _TalkState extends State<Talk> {
  bool favorite = false;
  bool alarm = false;

  @override
  void initState() {
    super.initState();
    favorite = widget.favorite!;
    alarm = widget.alarm!;
  }

  @override
  build(BuildContext bcontext) {
    return Card(
      child: Semantics(
        child: ListTile(
          title: Semantics(
              label: S.of(bcontext).talkLabelTitle(widget.title!),
              child: ExcludeSemantics(child: Text(widget.title!))),
          subtitle: getCardSubtitle(),
          leading: Ink(
            child: Consumer<FavoriteProvider>(
              builder: (context, favoriteProvider, child) => IconButton(
                tooltip: S.of(context).talkTooltipAdd(widget.title!),
                icon: Icon(
                  widget.favorite! ? Icons.favorite : Icons.favorite_border,
                ),
                onPressed: () {
                  DateTime day = DateTime(widget.start!.year,
                      widget.start!.month, widget.start!.day);
                  favoriteProvider.favoriteTalk(widget, day);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: widget.favorite == true
                        ? Text(S.of(context).talkFavAdded(widget.title!))
                        : Text(S.of(context).talkFavRemoved(widget.title!)),
                    action: SnackBarAction(
                      label: S.of(context).talkFavRevertButton,
                      onPressed: () =>
                          favoriteProvider.favoriteTalk(widget, day),
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
              tooltip: S.of(bcontext).talkTooltipInfo(widget.title!),
              icon: Icon(
                Icons.info,
                color: Colors.white,
              ),
              onPressed: () {
                showDialog(
                  context: bcontext,
                  builder: (BuildContext context) => SimpleDialog(
                    contentPadding: EdgeInsets.all(10),
                    title: Text('$widget.title'),
                    children: <Widget>[
                      BlockSemantics(
                        child: Column(
                          children: getDetails(context),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Semantics(
                            label: S.of(context).talkLabelCopyAbstract,
                            child: IconButton(
                              icon: Icon(Icons.content_copy),
                              tooltip: S.of(context).talkTooltipCopyAbstract,
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: widget.abstract));
                              },
                            ),
                          ),
                          Semantics(
                            label: S.of(context).talkLabelOpen(widget.title!),
                            child: ExcludeSemantics(
                              child: IconButton(
                                tooltip: S.of(context).talkTooltipOpen,
                                icon: Icon(
                                  Icons.open_in_browser,
                                ),
                                onPressed: () => openBrowser(
                                    Constants.getTalkUrl(widget.code!)),
                              ),
                            ),
                          ),
                          Semantics(
                            label: S.of(context).talkLabelShare(widget.title!),
                            child: ExcludeSemantics(
                              child: IconButton(
                                tooltip: S.of(context).talkTooltipShare,
                                icon: Icon(
                                  Icons.share,
                                ),
                                onPressed: () => Share.share(S
                                    .of(context)
                                    .shareTalkText(
                                        Constants.getTalkUrl(widget.code!))),
                              ),
                            ),
                          ),
                          alarm
                              ? Semantics(
                                  label: S
                                      .of(context)
                                      .talkLabelAlarmOff(widget.title!),
                                  child: ExcludeSemantics(
                                    child: IconButton(
                                      tooltip:
                                          S.of(context).talkTooltipAlarmOff,
                                      icon: Icon(
                                        Icons.alarm_off,
                                      ),
                                      onPressed: () {
                                        Alarm.stop(widget.code!.hashCode);
                                        setState(() {
                                          alarm = false;
                                        });
                                      },
                                    ),
                                  ),
                                )
                              : Semantics(
                                  label: S
                                      .of(context)
                                      .talkLabelAlarmOn(widget.title!),
                                  child: ExcludeSemantics(
                                    child: IconButton(
                                      tooltip: S.of(context).talkTooltipAlarmOn,
                                      icon: Icon(
                                        Icons.alarm_add,
                                      ),
                                      onPressed: () async {
                                        await Alarm.set(
                                            alarmSettings: AlarmSettings(
                                          id: widget.code!.hashCode,
                                          dateTime: widget.start!
                                              .subtract(Duration(minutes: 10)),
                                          assetAudioPath: 'assets/alarm.mp3',
                                          loopAudio: true,
                                          vibrate: true,
                                          fadeDuration: 3.0,
                                          notificationTitle: S
                                              .of(context)
                                              .alarmNotificationTitle,
                                          notificationBody: widget.title,
                                          enableNotificationOnKill: true,
                                        ));
                                        setState(() {
                                          alarm = true;
                                        });

                                        // store value
                                        ScaffoldMessenger.of(bcontext)
                                            .showSnackBar(SnackBar(
                                          content:
                                              Text(S.of(context).alarmSnackBar),
                                          action: SnackBarAction(
                                            label: S
                                                .of(bcontext)
                                                .talkFavRevertButton,
                                            onPressed: () {
                                              Alarm.stop(widget.code!.hashCode);
                                              alarm = false;
                                            },
                                          ),
                                          duration: Duration(seconds: 3),
                                        ));
                                      },
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
        ('${widget.startStr}' != ''
            ? ('${widget.room}' != ''
                ? '${widget.startStr}' + ' - '
                : '${widget.startStr}')
            : ' - ');
    textString = textString +
        ('${widget.room}' != ''
            ? ('${widget.track}' != ''
                ? '${widget.room}' + ' - '
                : '${widget.room}')
            : ' - ');
    textString =
        textString + ('${widget.track}' != '' ? '${widget.track}' : '');
    return Semantics(
        label:
            'Start ${widget.startStr}, Room ${widget.room}, Track ${widget.track}',
        child: ExcludeSemantics(child: Text(textString)));
  }

  List<Widget> getDetails(BuildContext context) {
    List<Widget> widgets = [];

    /// Add the start details
    if (widget.startStr != '') {
      widgets.add(
        Semantics(
          label: S.of(context).talkDetailsStartLabel(widget.startStr!),
          child: ExcludeSemantics(
            child: Row(
              children: <Widget>[
                Container(
                  child: Icon(Icons.access_time),
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                ),
                Text(
                  '${widget.startStr}',
                ),
              ],
            ),
          ),
        ),
      );
    }

    /// Add the duration details
    if (widget.duration! > 0) {
      widgets.add(
        Semantics(
          label: S.of(context).talkDetailsDurationLabel(widget.duration!),
          child: ExcludeSemantics(
            child: Row(
              children: <Widget>[
                Container(
                  child: Icon(Icons.hourglass_empty),
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                ),
                Text(S.of(context).talkDetailsDurationText(widget.duration!)),
              ],
            ),
          ),
        ),
      );
    }

    /// Add the room details
    if (widget.room != '') {
      widgets.add(
        Semantics(
          label: S.of(context).talkDetailsRoomLabel(widget.room!),
          child: ExcludeSemantics(
            child: Row(
              children: <Widget>[
                Container(
                  child: Icon(Icons.room),
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                ),
                Text('${widget.room}'),
              ],
            ),
          ),
        ),
      );
    }

    /// Add the track details
    if (widget.track != '') {
      widgets.add(
        Semantics(
          label: S.of(context).talkDetailsTrackLabel(widget.track!),
          child: ExcludeSemantics(
            child: Row(
              children: <Widget>[
                Container(
                  child: Icon(Icons.school),
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                ),
                Text(
                  '${widget.track}',
                ),
              ],
            ),
          ),
        ),
      );
    }

    /// Add the persons details
    if (widget.speakers!.length > 0) {
      for (Person p in widget.speakers!) {
        widgets.add(Semantics(
          label: S.of(context).talkDetailsSpeakerLabel(p.name!),
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
    if (widget.abstract != '') {
      widgets.add(
        Semantics(
          label: S.of(context).talkDetailsAbstractLabel(widget.abstract!),
          child: ExcludeSemantics(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    S.of(context).talkDetailsAbstractTitle,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${widget.abstract}'),
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
