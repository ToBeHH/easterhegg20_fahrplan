/*
congress_fahrplan
This is the dart file containing the AllTalks screen StatelessWidget
SPDX-License-Identifier: GPL-2.0-only
Copyright (C) 2019 - 2021 Benjamin Schilling
*/

import 'package:easterhegg20_fahrplan/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../provider/favorite_provider.dart';

class AllTalks extends StatelessWidget {
  final ThemeData? theme;

  AllTalks({Key? key, this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var favorites = Provider.of<FavoriteProvider>(context);
    return new MaterialApp(
      theme: theme,
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
