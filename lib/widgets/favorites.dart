/*
congress_fahrplan
This is the dart file containing the Favorites screen StatelessWidget
SPDX-License-Identifier: GPL-2.0-only
Copyright (C) 2019 - 2021 Benjamin Schilling
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      title: favorites.fahrplan!.getFahrplanTitle(),
      home: new DefaultTabController(
        length: favorites.fahrplan!.days!.length,
        child: new Scaffold(
          appBar: new AppBar(
            title: new Text(favorites.fahrplan!.getFavoritesTitle()),
            bottom: TabBar(
              tabs: favorites.fahrplan!.getDaysAsText(),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(color: Theme.of(context).indicatorColor),
              ),
            ),
          ),
          drawer: FahrplanDrawer(
            title: 'Favorites',
          ),
          body: TabBarView(
            children: favorites.fahrplan!.buildFavoriteList(),
          ),
        ),
      ),
    );
  }
}
