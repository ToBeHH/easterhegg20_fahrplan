import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../model/day.dart';
import '../model/fahrplan.dart';
import '../utilities/fahrplan_fetcher.dart';
import 'talk.dart';

class AlarmRingScreen extends StatelessWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingScreen({Key? key, required this.alarmSettings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<Fahrplan>(
            future: FahrplanFetcher.fetchFahrplan(
                true), // get the cached version of the Fahrplan
            builder: (BuildContext context, AsyncSnapshot<Fahrplan> snapshot) {
              if (snapshot.hasData) {
                Fahrplan fahrplan = snapshot.data!;
                Talk? foundTalk;
                for (Day day in fahrplan.days!) {
                  for (Talk talk in day.talks!) {
                    if (talk.code.hashCode == alarmSettings.id) {
                      foundTalk = talk;
                      break;
                    }
                  }
                  if (foundTalk != null) {
                    break;
                  }
                }
                return SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Text(
                            S.of(context).alarmTalkStarts(foundTalk!.title!),
                            style: Theme.of(context).textTheme.titleLarge,
                          )),
                      Text(
                        S.of(context).alarmTalkRoom(foundTalk.room!),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Text("🔔", style: TextStyle(fontSize: 50)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          RawMaterialButton(
                            onPressed: () {
                              final now = DateTime.now();
                              Alarm.set(
                                alarmSettings: alarmSettings.copyWith(
                                  dateTime: DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                    now.hour,
                                    now.minute,
                                    0,
                                    0,
                                  ).add(const Duration(minutes: 1)),
                                ),
                              ).then((_) => Navigator.pop(context));
                            },
                            child: Text(
                              S.of(context).alarmSnoozeButton,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          RawMaterialButton(
                            onPressed: () {
                              Alarm.stop(alarmSettings.id)
                                  .then((_) => Navigator.pop(context));
                            },
                            child: Text(
                              S.of(context).alarmStopButton,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }
}
