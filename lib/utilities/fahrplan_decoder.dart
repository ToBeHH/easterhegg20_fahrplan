/*
congress_fahrplan
This is the dart file containing the FahrplanDecoder class.
SPDX-License-Identifier: GPL-2.0-only
Copyright (C) 2019 - 2021 Benjamin Schilling
*/

import 'package:alarm/alarm.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../generated/l10n.dart';
import '../model/day.dart';
import '../model/fahrplan.dart';
import '../model/favorited_talks.dart';
import '../model/room.dart';
import '../model/settings.dart';
import '../widgets/talk.dart';

class FahrplanDecoder {
  // Decodes the Fahrplan, initializes it and sets all favorited talks
  Fahrplan decodeFahrplanFromJson(
      Map<String, dynamic> json,
      FavoritedTalks favTalks,
      Settings settings,
      FahrplanFetchState fetchState) {
    Fahrplan f = Fahrplan.fromJson(json, favTalks, settings, fetchState);

    // Rooms are initalized in f
    // Now initialize speakers
    List<Person> speakers = [];
    for (var rn in json['speakers']) {
      speakers.add(Person.fromJson(rn));
    }

    // Initialize talks
    tz.initializeTimeZones();
    List<Talk> talks = [];
    for (var rn in json['talks']) {
      talks.add(Talk.fromJson(
          rn, S.current.dateFormat, f.timezone!, speakers, f.rooms!));
    }

    // Initialize days from talks
    List<Day> days = [];
    for (Talk t in talks) {
      DateTime? date = DateTime(t.start!.year, t.start!.month, t.start!.day);
      if (days.any((day) => day.date == date)) {
        days.firstWhere((day) => day.date == date).talks!.add(t);
      } else {
        days.add(
            Day(index: days.length, date: date, talks: [t], rooms: f.rooms));
      }
    }
    f.days = days;
    // now add the talks to the rooms for each day
    for (Day d in f.days!) {
      for (Room r in d.rooms!) {
        for (Talk t in talks) {
          DateTime date = DateTime(t.start!.year, t.start!.month, t.start!.day);
          if (t.room == r.name && date == d.date) {
            r.talks!.add(t);
          }
        }
      }
    }

    //set all favorites talks for each day and each rooms of each day
    for (String i in f.favTalkIds!.ids) {
      for (Day d in f.days!) {
        for (Talk t in d.talks!) {
          if (t.code == i) {
            f.favoriteTalks!.add(t);
            d.talks!.elementAt(d.talks!.indexOf(t)).favorite = true;
            break;
          }
        }
        for (Room r in d.rooms!) {
          for (Talk t in r.talks!) {
            if (t.code == i) {
              f.favoriteTalks!.add(t);
              r.talks!.elementAt(r.talks!.indexOf(t)).favorite = true;
              break;
            }
          }
        }
      }
      // set alarms
      var alarms = Alarm.getAlarms();
      for (AlarmSettings alarm in alarms) {
        for (Day d in f.days!) {
          d.talks!.forEach((t) {
            if (t.code.hashCode == alarm.id) {
              t.alarm = true;
            }
          });
        }
        for (Room r in f.rooms!) {
          r.talks!.forEach((t) {
            if (t.code.hashCode == alarm.id) {
              t.alarm = true;
            }
          });
        }
      }
    }

    // filter for duplicates
    for (Day d in f.days!) {
      // get talk codes:
      List<String> codes = [];
      for (Talk t in d.talks!) {
        if (codes.contains(t.code)) {
          d.talks!.remove(t);
        } else {
          codes.add(t.code!);
        }
      }
    }
    for (Room r in f.rooms!) {
      List<String> codes = [];
      for (Talk t in r.talks!) {
        if (codes.contains(t.code)) {
          r.talks!.remove(t);
        } else {
          codes.add(t.code!);
        }
      }
    }

    /// Sort favorites
    f.favoriteTalks!.sort((a, b) => a.start!.compareTo(b.start!));
    return f;
  }
}
