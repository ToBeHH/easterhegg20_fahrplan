/*
congress_fahrplan
This is the dart file containing the SyncCalendar StatelessWidget.
SPDX-License-Identifier: GPL-2.0-only
Copyright (C) 2019 - 2021 Benjamin Schilling
*/

import 'dart:collection';
import 'dart:core';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../generated/l10n.dart';
import '../model/day.dart';
import '../model/room.dart';
import '../provider/favorite_provider.dart';
import '../widgets/talk.dart';

class SyncCalendar extends StatelessWidget {
  final DeviceCalendarPlugin? calendarPlugin;
  final FavoriteProvider? provider;
  SyncCalendar({this.calendarPlugin, this.provider});

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: calendarPlugin!.retrieveCalendars(),
      builder: (BuildContext context,
          AsyncSnapshot<Result<UnmodifiableListView<Calendar>>> snapshot) {
        if (snapshot.hasData) {
          Result<UnmodifiableListView<Calendar>> calendarResults =
              snapshot.data!;
          UnmodifiableListView<Calendar> calendars = calendarResults.data!;
          return Container(
            height: 300,
            width: 300,
            child: ListView.builder(
              itemCount: calendars.length,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.sync),
                      Container(
                        width: 200,
                        child: Text(
                          calendars[index].name!,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () =>
                      syncCalendar(context, provider!, calendars[index]),
                );
              },
            ),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }

  syncCalendar(BuildContext context, FavoriteProvider provider,
      Calendar calendar) async {
    /// Get all events from calendar
    Result<UnmodifiableListView<Event>> resultExistingEvents =
        await calendarPlugin!.retrieveEvents(
            calendar.id,
            RetrieveEventsParams(
                startDate: provider.fahrplan!.start!,
                endDate: provider.fahrplan!.end!));
    UnmodifiableListView<Event>? calendarEvents = resultExistingEvents.data;
    print(provider.fahrplan!.start!);
    print(provider.fahrplan!.end!);
    print(calendarEvents);

    /// Sync calendar to favorites
    for (Event calendarEvent in calendarEvents!) {
      for (Day d in provider.fahrplan!.days!) {
        if (d.date!.year == calendarEvent.start?.year &&
            d.date!.month == calendarEvent.start?.month &&
            d.date!.day == calendarEvent.start?.day) {
          for (Talk t in d.talks!) {
            if (t.title == calendarEvent.title) {
              if (!t.favorite!) {
                provider.favoriteTalk(t, d.date!);
              }
            }
          }
        }
      }
    }

    /// Sync favorites to calendar
    for (Talk fav in provider.fahrplan!.favoriteTalks!) {
      bool eventFound = false;

      /// Search for event in calendar
      for (Event calendarEvent in calendarEvents) {
        if (calendarEvent.title == fav.title) {
          eventFound = true;
        }
      }
      print("Event ${fav.title} found: $eventFound");

      /// If event not found, add it
      if (!eventFound) {
        Event e = Event(calendar.id);
        e.title = fav.title;
        tz.initializeTimeZones();
        e.start = TZDateTime.from(
            fav.start!, getLocation(provider.fahrplan!.timezone!));
        e.description = fav.abstract;
        e.location = provider.fahrplan!.rooms
            ?.firstWhere((element) => element.id == fav.room,
                orElse: () => Room(id: 0, name: ''))
            .name;
        e.end = TZDateTime.from(
            fav.end!, getLocation(provider.fahrplan!.timezone!));
        calendarPlugin!.createOrUpdateEvent(e);
      }
    }
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(S.of(context).syncCalendarSuccessTitle),
        actions: <Widget>[
          TextButton(
            child: Text(S.of(context).syncCalendarSuccessButton),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }
}
