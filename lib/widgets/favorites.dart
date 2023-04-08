/*
congress_fahrplan
This is the dart file containing the Favorites screen StatelessWidget
SPDX-License-Identifier: GPL-2.0-only
Copyright (C) 2019 - 2021 Benjamin Schilling
*/

import 'package:easterhegg20_fahrplan/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../provider/favorite_provider.dart';
import '../widgets/fahrplan_drawer.dart';

class Favorites extends StatelessWidget {
  Favorites({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The StoreProvider should wrap your MaterialApp or WidgetsApp. This will
    // ensure all routes have access to the store.
    var favorites = Provider.of<FavoriteProvider>(context);
    return new MaterialApp(
      theme: Theme.of(context),
      title: S.of(context).overviewTitleWithEvent(Constants.acronym),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: new DefaultTabController(
        length: favorites.fahrplan!.days!.length,
        child: new Scaffold(
          appBar: new AppBar(
            title: new Text(
                S.of(context).favoritesTitleWithEvent(Constants.acronym)),
            bottom: TabBar(
              tabs: favorites.fahrplan!.getDaysAsText(context),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(color: Theme.of(context).indicatorColor),
              ),
            ),
          ),
          drawer: FahrplanDrawer(
            title: S.of(context).favoritesTitle,
          ),
          body: TabBarView(
            children: favorites.fahrplan!.buildFavoriteList(),
          ),
        ),
      ),
    );
  }
}
