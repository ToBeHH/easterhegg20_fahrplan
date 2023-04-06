/*
congress_fahrplan
This is the dart file containing the Day class.
SPDX-License-Identifier: GPL-2.0-only
Copyright (C) 2019 - 2021 Benjamin Schilling
*/

import '../model/room.dart';
import '../widgets/talk.dart';

class Day {
  final int? index;
  final DateTime? date;

  final List<Room>? rooms;
  final List<Talk>? talks;

  Day({this.index, this.date, this.rooms, this.talks});
}
