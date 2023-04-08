/*
congress_fahrplan
This is the dart file containing the FahrplanDrawer StatelessWidget.
SPDX-License-Identifier: GPL-2.0-only
Copyright (C) 2019 - 2021 Benjamin Schilling
*/

import 'package:device_calendar/device_calendar.dart';
import 'package:easterhegg20_fahrplan/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n.dart';
import '../provider/favorite_provider.dart';
import '../widgets/all_talks.dart';
import '../widgets/favorites.dart';
import '../widgets/flat_icon_text_button.dart';
import '../widgets/sync_calendar.dart';

class FahrplanDrawer extends StatelessWidget {
  final String? title;
  FahrplanDrawer({this.title});

  @override
  build(BuildContext context) {
    var favorites = Provider.of<FavoriteProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        title: Text(
          '$title',
          style: Theme.of(context).textTheme.headline6,
        ),
        leading: Semantics(
          label: S.of(context).drawerLabelClose,
          child: IconButton(
            icon: Icon(Icons.navigate_before),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          title! == S.of(context).favoritesTitle // it is exactly this string
              ? FlatIconTextButton(
                  icon: Icons.calendar_today,
                  text: S.of(context).drawerOverviewButton,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return AllTalks(
                            theme: Theme.of(context),
                          );
                        },
                      ),
                    );
                  },
                )
              : FlatIconTextButton(
                  icon: Icons.favorite,
                  text: S.of(context).drawerFavouritesButton,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Favorites(),
                      ),
                    );
                  },
                ),
          FlatIconTextButton(
            icon: Icons.sync,
            text: S.of(context).drawerSyncCalendarButton,
            onPressed: () => showSyncCalendar(context, favorites),
          ),
          FlatIconTextButton(
            icon: Icons.share,
            text: S.of(context).drawerShareAppButton,
            onPressed: () => Share.share(
                S.of(context).shareThisApp(Constants.PLAYSTORE_URL)),
          ),
          FlatIconTextButton(
            icon: Icons.security,
            text: S.of(context).drawerPrivacyPolicyButton,
            onPressed: () => openBrowser(Constants.PRIVACY_POLICY_URL),
          ),
          FlatIconTextButton(
            icon: Icons.bug_report,
            text: S.of(context).drawerReportBugButton,
            onPressed: () => openBrowser(Constants.REPORT_BUG_URL),
          ),
          FlatIconTextButton(
            icon: Icons.color_lens,
            text: 'Design adapted from\nrC3 design by kreatur.works',
            onPressed: () => openBrowser('https://kreatur.works/'),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(32, 0, 0, 0),
            child: Text(
              S.of(context).version(favorites.packageVersion),
            ),
          ),
        ],
      ),
    );
  }

  openBrowser(String url) {
    Uri uri = Uri.parse(url);
    launchUrl(uri); // async, but we don't care
  }

  showSyncCalendar(BuildContext context, FavoriteProvider favorites) async {
    DeviceCalendarPlugin deviceCalendar = DeviceCalendarPlugin();
    Result<bool> permissionsAvailable = await deviceCalendar.hasPermissions();
    if (!permissionsAvailable.data!) {
      permissionsAvailable = await deviceCalendar.requestPermissions();
    }
    if (permissionsAvailable.data!) {
      showDialog(
        context: context,
        builder: (BuildContext context) => SimpleDialog(
          contentPadding: EdgeInsets.all(10),
          title: Text(S.of(context).drawerSyncCalendarTitle),
          children: <Widget>[
            SyncCalendar(
              calendarPlugin: deviceCalendar,
              provider: favorites,
            ),
          ],
        ),
      );
    }
  }
}
