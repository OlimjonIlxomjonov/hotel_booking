// Step 2: tests that describe what the P03 app does today.
// They must pass before the refactoring and still pass after it.
import 'package:hotel_booking/hotel_booking.dart';
import 'package:test/test.dart';

final r7 = Room('R7', 'Standard');
final r8 = Room('R8', 'Deluxe');
final maya = Guest('Maya', 'maya@example.com');
final omar = Guest('Omar', 'omar@example.com');
final nora = Guest('Nora', 'nora@example.com');

DateRange nov(int checkIn, int checkOut) =>
    DateRange(DateTime.utc(2026, 11, checkIn), DateTime.utc(2026, 11, checkOut));

// The only place that builds the service: a refactoring changes this record, not every test.
({BookingService service, ReservationStore store, EmailSender email}) newService() {
  final store = ReservationStore();
  final email = EmailSender();
  return (
    service: BookingService([r7, r8], store, email),
    store: store,
    email: email,
  );
}

void main() {
  test('Maya gets R7 when it is free', () async {
    final fixture = newService();
    expect('${await fixture.service.reserve(maya, r7, nov(12, 14))}', 'Accepted R101');
  });

  test('Omar is refused when a night is shared', () async {
    final fixture = newService();
    await fixture.service.reserve(maya, r7, nov(12, 14));
    expect('${await fixture.service.reserve(omar, r7, nov(13, 15))}', 'Unavailable');
    expect(fixture.store.count, 1);
  });

  test('Nora can arrive on the day Maya leaves', () async {
    final fixture = newService();
    await fixture.service.reserve(maya, r7, nov(12, 14));
    expect('${await fixture.service.reserve(nora, r7, nov(14, 16))}', 'Accepted R102');
  });

  test('check-out must be after check-in', () async {
    final fixture = newService();
    expect('${await fixture.service.reserve(omar, r8, nov(15, 15))}', 'InvalidDates');
    expect(fixture.store.count, 0);
  });

  test('cancelling frees the room again', () async {
    final fixture = newService();
    await fixture.service.reserve(maya, r7, nov(12, 14));
    expect(fixture.service.cancel('R101'), isTrue);
    expect(fixture.service.findFreeRooms(nov(12, 14)), contains(r7));
  });

  test('one confirmation per accepted booking', () async {
    final fixture = newService();
    await fixture.service.reserve(maya, r7, nov(12, 14));
    await fixture.service.reserve(omar, r7, nov(13, 15));
    await fixture.service.reserve(nora, r7, nov(14, 16));
    expect(fixture.email.sent, 2);
  });
}
