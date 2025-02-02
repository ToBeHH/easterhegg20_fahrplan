/*
congress_fahrplan
This is the dart file containing the main method, the ThemeWrapper and the CongressFahrplanApp class.
SPDX-License-Identifier: GPL-2.0-only
Copyright (C) 2019 -2021 Benjamin Schilling
*/

import 'package:alarm/alarm.dart';
import 'package:easterhegg20_fahrplan/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'generated/l10n.dart';
import 'model/fahrplan.dart';
import 'provider/favorite_provider.dart';
import 'widgets/all_talks.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  await Alarm.init();
  runApp(ThemeWrapper());
}

class ThemeWrapper extends StatelessWidget {
  ThemeWrapper({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return new MaterialApp(
      title: Constants.acronym,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      theme: ThemeData(
        brightness: Brightness.dark,
        backgroundColor: Color(0xff000000),
        tabBarTheme: TabBarTheme(
          indicator: UnderlineTabIndicator(),
        ),
        primaryColorDark: Color(0xff000000),
        indicatorColor: Color(0xFF4D7FFA),
        accentColor: Color(0xFF4D7FFA),
        textTheme: TextTheme(
          headline6: TextStyle(
            color: Color(0xFFD0D0CE),
          ),
          bodyText2: TextStyle(
            color: Color(0xFFD0D0CE),
          ),
          bodyText1: TextStyle(
            color: Color(0xFFD0D0CE),
          ),
          subtitle2: TextStyle(
            color: Color(0xFFD0D0CE),
          ),
          subtitle1: TextStyle(
            color: Color(0xFFD0D0CE),
          ),
          headline4: TextStyle(
            color: Color(0xFFD0D0CE),
          ),
          caption: TextStyle(
            color: Color(0xFFD0D0CE),
          ),
          overline: TextStyle(
            color: Color(0xFFD0D0CE),
          ),
          headline5: TextStyle(
            color: Color(0xFFD0D0CE),
          ),
        ),
        cardColor: Color(0xFF3b3b3b),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Color(0xFF4d4d4d),
          actionTextColor: Color(0xFF4D7FFA),
          contentTextStyle: TextStyle(
            color: Color(0xFFD0D0CE),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          elevation: 30,
        ),
        appBarTheme: AppBarTheme(
          color: Color(0xFF1a1a1a),
          iconTheme: IconThemeData(
            color: Color(0xFF4D7FFA),
          ),
        ),
        buttonColor: Color(0xFF4D7FFA),
        iconTheme: IconThemeData(
          color: Color(0xFF4D7FFA),
        ),
        toggleableActiveColor: Color(0xFF4D7FFA),
      ),
      home: CongressFahrplanApp(key: key),
    );
  }
}

class CongressFahrplanApp extends StatelessWidget {
  CongressFahrplanApp({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FavoriteProvider(false),
      child: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) => FutureBuilder<Fahrplan>(
          future: favoriteProvider.futureFahrplan,
          builder: (context, AsyncSnapshot<Fahrplan> snapshot) {
            if (snapshot.hasData) {
              favoriteProvider.initializeProvider(snapshot.data!);
              if (favoriteProvider.fahrplan!.fetchState ==
                  FahrplanFetchState.successful) {
                return AllTalks(
                  theme: Theme.of(context),
                );
              } else {
                return SafeArea(
                  child: Scaffold(
                    backgroundColor: Color(0xffffffff),
                    body: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset('assets/eh20logo-2023.png'),
                        Text(
                          S.of(context).loadingError,
                        ),
                        Text(
                          favoriteProvider.fahrplan!.fetchMessage!,
                        ),
                      ],
                    ),
                  ),
                );
              }
            } else {
              return SafeArea(
                child: Scaffold(
                  backgroundColor: Color(0xffffffff),
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.fromLTRB(40, 40, 40, 40),
                          child: Image.asset('assets/eh20logo-2023.png')),
                      CircularProgressIndicator(),
                      Container(
                        child: Text(S.of(context).loading),
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
