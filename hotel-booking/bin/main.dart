import 'package:hotel_booking/hotel_booking.dart';

Future<void> main(List<String> args) async {
  if (args.contains('--race')) {
    await runRace();
  } else {
    await runDemo();
  }
}
