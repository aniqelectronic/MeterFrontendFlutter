import 'package:frontend_v1/pages/config.dart';

class IimmpactRefIdService {
  IimmpactRefIdService._();

  static String generate() {
    final DateTime now =
        DateTime.now();

    final String year =
        (now.year % 100)
            .toString()
            .padLeft(2, '0');

    final String month =
        now.month
            .toString()
            .padLeft(2, '0');

    final String day =
        now.day
            .toString()
            .padLeft(2, '0');

    final String hour =
        now.hour
            .toString()
            .padLeft(2, '0');

    final String minute =
        now.minute
            .toString()
            .padLeft(2, '0');

    final String second =
        now.second
            .toString()
            .padLeft(2, '0');

    final String millisecond =
        now.millisecond
            .toString()
            .padLeft(3, '0');

    final String terminalId =
        Config.terminalId
            .trim()
            .replaceAll(
              RegExp(r'[^A-Za-z0-9_-]'),
              '',
            );

    return 'TIP-$terminalId-'
        '$year$month$day'
        '$hour$minute$second'
        '$millisecond';
  }
}