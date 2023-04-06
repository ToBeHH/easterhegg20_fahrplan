/*
congress_fahrplan
This is the dart file containing the FavoritedTalks class needed by the Fahrplan class.
SPDX-License-Identifier: GPL-2.0-only
Copyright (C) 2019 - 2021 Benjamin Schilling
*/

import '../utilities/file_storage.dart';

class FavoritedTalks {
  final List<String> ids;

  FavoritedTalks({required this.ids});

  factory FavoritedTalks.fromJson(Map json) {
    return FavoritedTalks(
      ids: json['ids'].cast<int>(),
    );
  }

  void addFavoriteTalk(String id) {
    ids.add(id);
    FileStorage.writeFavoritesFile('{"ids": $ids}');
  }

  void removeFavoriteTalk(String id) {
    ids.remove(id);
    FileStorage.writeFavoritesFile('{"ids": $ids}');
  }
}
