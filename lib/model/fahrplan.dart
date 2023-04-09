/*
congress_fahrplan
This is the dart file containing the Fahrplan class.
SPDX-License-Identifier: GPL-2.0-only
Copyright (C) 2019 - 2021 Benjamin Schilling
*/

import 'package:easterhegg20_fahrplan/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_view_indicators/linear_progress_page_indicator.dart';

import '../generated/l10n.dart';
import '../model/favorited_talks.dart';
import '../model/settings.dart';
import '../widgets/fahrplan_drawer.dart';
import '../widgets/talk.dart';
import 'day.dart';
import 'room.dart';

enum FahrplanFetchState {
  successful,
  timeout,
  noDataConnection,
  noFile,
}

class Fahrplan {
  final String? version;
  final String? timezone;
  final FahrplanFetchState? fetchState;
  final String? fetchMessage;

  List<Day>? days;
  List<Room>? rooms;

  List<Talk>? favoriteTalks;
  FavoritedTalks? favTalkIds;

  Widget? dayTabCache;

  final currentPageNotifier = ValueNotifier<int>(0);
  final PageStorageBucket bucket = PageStorageBucket();

  final Settings? settings;

  final DateTime? start;
  final DateTime? end;

  Fahrplan(
      {this.version,
      this.timezone,
      this.days,
      this.rooms,
      this.favTalkIds,
      this.favoriteTalks,
      this.settings,
      this.fetchState,
      this.fetchMessage,
      this.start,
      this.end});

  factory Fahrplan.fromJson(var json, FavoritedTalks favTalks,
      Settings settings, FahrplanFetchState fetchState) {
    DateTime minStart = DateTime.parse(json['talks'][0]['start']);
    DateTime maxEnd = DateTime.parse(json['talks'][0]['end']);
    for (var talk in json['talks']) {
      DateTime s = DateTime.parse(talk['start']);
      DateTime e = DateTime.parse(talk['end']);
      if (s.isBefore(minStart)) {
        minStart = s;
      }
      if (e.isAfter(maxEnd)) {
        maxEnd = e;
      }
    }

    print("Conference goes from: $minStart, to: $maxEnd");

    return Fahrplan(
      version: json['version'],
      timezone: json['timezone'],
      days: List<Day>.empty(growable: true),
      rooms: Room.jsonToRoomList(json['rooms']),
      favTalkIds: favTalks,
      favoriteTalks: List<Talk>.empty(growable: true),
      settings: settings,
      fetchState: fetchState,
      start: minStart,
      end: maxEnd,
    );
  }

  Widget buildDayLayout(BuildContext context) {
    dayTabCache = TabBarView(
      children: buildDayTabs(),
    );
    return new DefaultTabController(
      length: days!.length,
      child: new Scaffold(
        appBar: new AppBar(
          title: Text(S.of(context).overviewTitleWithEvent(Constants.acronym)),
          bottom: PreferredSize(
            child: TabBar(
              tabs: getDaysAsText(context),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(color: Theme.of(context).indicatorColor),
              ),
            ),
            preferredSize: Size.fromHeight(50),
          ),
        ),
        drawer: FahrplanDrawer(
          title: S.of(context).overviewTitle,
        ),
        body: dayTabCache,
      ),
    );
  }

  List<Widget> buildDayTabs() {
    List<Column> dayColumns = [];
    for (Day d in days!) {
      if (d.talks!.length > 0) {
        List<Widget> widgets = [];
        widgets.addAll(d.talks!);
        dayColumns.add(
          Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: d.talks!.length,
                  itemBuilder: (context, index) {
                    return d.talks![index];
                  },
                ),
              ),
            ],
          ),
        );
      }
    }
    return dayColumns;
  }

  List<Widget> getDaysAsText(BuildContext context) {
    List<Widget> dayTexts = [];
    DateTime today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    for (Day d in days!) {
      if (d.talks!.length == 0) {
        continue;
      }

      String dateString =
          DateFormat(S.of(context).dayDateFormat).format(d.date!);
      String semanticsDay = new DateFormat.EEEE().format(d.date!) +
          ' ' +
          new DateFormat.yMMMMd().format(d.date!);
      dayTexts.add(
        new Semantics(
          label: semanticsDay,
          focused: today == d.date!,
          child: ExcludeSemantics(
            child: Text(
              dateString,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }
    return dayTexts;
  }

  /// Room layout is shown when in landscape mode
  Widget buildRoomLayout(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text(S.of(context).overviewTitleWithEvent(Constants.acronym) +
            ' - This view is still experimental'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constrains) =>
                LinearProgressPageIndicator(
              itemCount: rooms!.length,
              currentPageNotifier: currentPageNotifier,
              progressColor: Theme.of(context).indicatorColor,
              width: constrains.maxWidth,
              height: 10,
            ),
          ),
          Expanded(
            child: PageStorage(
              bucket: bucket,
              child: PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: days!.length + 1,
                controller: PageController(viewportFraction: 0.90),
                itemBuilder: (BuildContext context, int index) {
                  return _buildCarousel(context,
                      days![index >= days!.length ? index - 1 : index], index);
                },
              ),
            ),
          ),
        ],
      ),
      drawer: FahrplanDrawer(
        title: 'Overview',
      ),
    );
  }

  Widget _buildCarousel(BuildContext context, Day d, int index) {
    if (index >= days!.length) {
      return Column();
    } else {
      return Column(
        key: PageStorageKey(d.date.toString() + '$index'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: PageView.builder(
              // store this controller in a State to save the carousel scroll position
              itemCount: d.rooms!.length,
              controller: PageController(viewportFraction: 0.85),
              itemBuilder: (BuildContext context, int itemIndex) {
                return buildRoom(
                    context, itemIndex, d, d.rooms![itemIndex].name!);
              },
              onPageChanged: (int itemIndex) {
                currentPageNotifier.value = itemIndex;
              },
            ),
          ),
        ],
      );
    }
  }

  Widget buildRoom(
      BuildContext context, int itemIndex, Day d, String roomName) {
    int month = d.date!.month;
    int day = d.date!.day;
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).appBarTheme.backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        child: Column(
          children: <Widget>[
            Text('$month-$day - $roomName'),
            Expanded(
              child: ListView.builder(
                itemCount: d.rooms![itemIndex].talks!.length,
                itemBuilder: (context, index) {
                  return d.rooms![itemIndex].talks![index];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildFavoriteList() {
    List<Column> dayColumns = [];
    for (Day d in days!) {
      List<Widget> widgets = [];
      widgets.addAll(favoriteTalks!
          .where((talk) => talk.start!.day == d.date!.day)
          .where((talk) => days!
              .firstWhere((date) => date.date!.day == talk.start!.day)
              .talks!
              .contains(talk)));
      dayColumns.add(
        Column(
          children: <Widget>[
            Expanded(
              child: new ListView.builder(
                itemCount: widgets.length,
                itemBuilder: (context, index) {
                  return widgets[index];
                },
              ),
            ),
          ],
        ),
      );
    }
    return dayColumns;
  }
}
