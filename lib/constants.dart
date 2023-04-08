/**
 * Global constants
 */
class Constants {
  static String FAHRPLAN_URL =
      'https://cfp.eh20.easterhegg.eu/eh20/schedule/v/0.20/widget/v2.json';

  static String PLAYSTORE_URL =
      "https://play.google.com/store/apps/details?id=de.schulzhess.easterhegg20_fahrplan";

  static String PRIVACY_POLICY_URL =
      "https://github.com/ToBeHH/easterhegg20_fahrplan/wiki/Datenschutzerkl%C3%A4rung---Privacy-Policy";

  static String REPORT_BUG_URL =
      "https://github.com/ToBeHH/easterhegg20_fahrplan/issues";

  static String get acronym => "Easterhegg20";

  static getTalkUrl(talkId) {
    return "https://cfp.eh20.easterhegg.eu/eh20/talk/${talkId}";
  }
}