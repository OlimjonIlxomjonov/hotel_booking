Future<void> main(List<String> args) async {
  if (args.contains('--race')) {
    await runRace();
  } else {
    await runDemo();
  }
}

Future<void> runDemo() async {
  final store = ReservationStore();
  final email = EmailSender();
  final service = BookingService([r7, r8], store, email);

  print('Free rooms 12-14 Nov: ${names(service.findFreeRoom(nov(12, 14)))}');
  print('Maya books R7 12-14 Nov: ${await service.reserve(maya, r7, nov(12, 14))}');
  print('Omar books R7 13-15 Nov: ${await service.reserve(omar, r7, nov(13, 15))}');
  print('Nora books R7 14-16 Nov: ${await service.reserve(nora, r7, nov(14, 16))}');
  print('Omar books R8 15-15 Nov: ${await service.reserve(omar, r8, nov(15, 15))}');
  print('Free rooms 12-14 Nov: ${names(service.findFreeRoom(nov(12, 14)))}');
  print('Maya cancels R101: ${boolText(service.cancel('R101'))}');
  print('Free rooms 12-14 Nov: ${names(service.findFreeRoom(nov(12, 14)))}');
  print('Confirmation emails sent: ${email.sent}');
}

Future<void> runRace() async {
  final store = ReservationStore();
  final service = BookingService(
    [r7, r8],
    store,
    EmailSender(),
    slowStep: const Duration(milliseconds: 500),
  );
  final stay = nov(12, 14);

  print('Maya and Omar both book R7 for 12-14 Nov at the same moment...');
  final mayaRequest = service.reserve(maya, r7, stay);
  await Future<void>.delayed(const Duration(milliseconds: 100));
  final omarRequest = service.reserve(omar, r7, stay);
  final results = await Future.wait([mayaRequest, omarRequest]);

  print('Maya: ${results[0]}');
  print('Omar: ${results[1]}');
  final confirmed = store.countConfirmed(r7, stay);
  print('Confirmed reservations for R7 on 12-14 Nov: $confirmed');
  print(
    confirmed > 1
        ? 'Double booking! Both requests checked before either one saved.'
        : 'Only one guest has R7.',
  );
}



class DateRange {

final DateTime checkIn;
final DateTime checkOut;

  DateRange(this.checkIn, this.checkOut);

  bool isValid() => checkOut.isAfter(checkIn);

  bool overlaps(DateRange other) => checkIn.isBefore(other.checkOut) && other.checkIn.isBefore(other.checkOut);

}


class Guest {
  final String name, email;
  const Guest(this.name, this.email);
 }

 class Room {
  final String number, type;
  Room(this.number, this.type);
 
 
  @override
  bool operator == (Object other) => other is Room && other.number == number && other.type == type;

  @override
  int get hashCode => Object.hash(number, type);
  
 }

enum ReservationStatus { confirmed, cancelled }

class Reservation {
  final String id;
  final Guest guest;
  final Room room;
  final DateRange stay;
  ReservationStatus status = ReservationStatus.confirmed;

  Reservation(this.id, this.guest, this.room, this.stay);

  bool blocks(Room room, DateRange stay) => status == ReservationStatus.confirmed && this.room == room && this.stay.overlaps(stay);
  
  bool cancel()  {
    if(status == ReservationStatus.cancelled) return false;
    status = ReservationStatus.cancelled;
    return true;
  }
  }

  class ReservationStore {
    final List<Reservation> _rows = []; 

    int get count => _rows.length;
    bool hasOverlap(Room room, DateRange stay) => _rows.any((row) => row.blocks(room, stay));

    void save(Reservation reservation) => _rows.add(reservation); 

    Reservation? find(String id) {
      for(final row in  _rows) {
        if(row.id == id) return row;
      }
      return null;
    }

    int countConfirmed(Room room, DateRange stay) => _rows.where((row) => row.blocks(room, stay)).length; 

  }


class EmailSender {
  int sent = 0;

  void sendConfirmation(Reservation reservation) => sent++;
}

class BookingResult {
  
  final String outcome;
  final String? reservationId;

  BookingResult(this.outcome, [this.reservationId]);

  @override
  String toString() => reservationId == null ? outcome : '$outcome $reservationId';

}


class BookingService {
  final List<Room> rooms;
  final ReservationStore store;
  final EmailSender emailSender;
  final Duration slowStep;

BookingService(this.rooms, this.store, this.emailSender, {this.slowStep = Duration.zero});
List<Room> findFreeRoom(DateRange stay) => rooms.where((room) => !store.hasOverlap(room,stay)).toList();


Future<BookingResult> reserve(Guest guest, Room room, DateRange stay) async {
  if(!stay.isValid()) return BookingResult("InvalidDates");
  if(store.hasOverlap(room, stay)) return BookingResult("Unavailable");

  await Future<void>.delayed(slowStep);

  final reservation = Reservation('R${101 + store.count}', guest, room, stay);
  store.save(reservation);
  emailSender.sendConfirmation(reservation);
  return BookingResult('Accapted', reservation.id);
}

bool cancel(String reservationId) => store.find(reservationId)?.cancel() ?? false;

}


// DEMO

final r7 = Room('R7', 'Standard');
final r8 = Room('R8', 'Deluxe');
final maya = Guest('Maya', 'maya@example.com');
final omar = Guest('Omar', 'omar@example.com');
final nora = Guest('Nora', 'nora@example.com');

DateRange nov(int checkIn, int checkOut) =>
    DateRange(DateTime.utc(2026, 11, checkIn), DateTime.utc(2026, 11, checkOut));

String names(List<Room> rooms) => rooms.map((room) => room.number).join(', ');

String boolText(bool value) => value ? 'True' : 'False';



