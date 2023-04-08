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
import '../utilities/fahrplan_fetcher.dart';

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
            Future.delayed(
                Duration.zero, () => openOutdatedDialog(context, favorites));
            return favorites.fahrplan!.buildDayLayout(context);
          } else {
            ///Landscape Orientation
            Future.delayed(
                Duration.zero, () => openOutdatedDialog(context, favorites));
            return favorites.fahrplan!.buildRoomLayout(context);
          }
        },
      ),
    );
  }

  openOutdatedDialog(BuildContext context, FavoriteProvider provider) {
    /// Show only when URLs are outdated and notice has not been dismissed yet
    if ((FahrplanFetcher.oldUrls
                .contains(FahrplanFetcher.completeFahrplanUrl) ||
            FahrplanFetcher.oldUrls.contains(Constants.FAHRPLAN_URL)) &&
        !provider.oldTalkNoticeDismissed) {
      showDialog(
        context: context,
        builder: (BuildContext context) => SimpleDialog(
          contentPadding: EdgeInsets.all(10),
          title: Text(S.of(context).oldTalkNoticeTitle),
          children: <Widget>[
            Semantics(
              label: S.of(context).oldTalkLabelDismiss,
              child: ExcludeSemantics(
                child: TextButton(
                  onPressed: () {
                    provider.oldTalkNoticeDismissed = true;
                    Navigator.pop(context);
                  },
                  child: Text(S.of(context).oldTalkLabelText),
                ),
              ),
            )
          ],
        ),
      );
    }
  }
}
