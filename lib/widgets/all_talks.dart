/*
congress_fahrplan
This is the dart file containing the AllTalks screen StatelessWidget
SPDX-License-Identifier: GPL-2.0-only
Copyright (C) 2019 - 2021 Benjamin Schilling
*/

import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:easterhegg20_fahrplan/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../provider/favorite_provider.dart';
import 'alarm_ring_screen.dart';

class AllTalks extends StatefulWidget {
  final ThemeData? theme;
  const AllTalks({Key? key, this.theme}) : super(key: key);

  @override
  State<AllTalks> createState() => _AllTalksState();
}

class _AllTalksState extends State<AllTalks> {
  static StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    //loadAlarms();
    subscription ??= Alarm.ringStream.stream.listen(
      (alarmSettings) => navigateToRingScreen(alarmSettings),
    );
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AlarmRingScreen(alarmSettings: alarmSettings),
        ));
    //loadAlarms();
  }

  @override
  Widget build(BuildContext context) {
    var favorites = Provider.of<FavoriteProvider>(context);
    return new MaterialApp(
      theme: widget.theme,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      title: S.of(context).overviewTitleWithEvent(Constants.acronym),
      home: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            ///Portrait Orientation
            return favorites.fahrplan!.buildDayLayout(context);
          } else {
            ///Landscape Orientation
            return favorites.fahrplan!.buildRoomLayout(context);
          }
        },
      ),
    );
  }
}
