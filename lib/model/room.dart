/*
congress_fahrplan
This is the dart file containing the Room StatelessWidget.
SPDX-License-Identifier: GPL-2.0-only
Copyright (C) 2019 - 2021 Benjamin Schilling
*/

import 'package:flutter/material.dart';

import '../widgets/talk.dart';

class Room extends StatelessWidget {
  final String? name;
  final int? id;

  static int numberOfRooms = 0;
  static List<String> namesOfRooms = [];

  List<Talk>? talks = [];

  Room({
    this.id,
    this.name,
  });

  factory Room.fromJson(var json) {
    return Room(id: json['id'], name: json['name']['de']);
  }

  @override
  build(BuildContext context) {
    return Card();
  }

  static List<Room> jsonToRoomList(json) {
    List<Room> roomList = [];
    for (var rn in json) {
      roomList.add(Room.fromJson(rn));
    }
    return roomList;
  }
}
