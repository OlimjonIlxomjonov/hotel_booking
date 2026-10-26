# PO3 desing notes
## Why desing before code
"Low level desing descides what should be in that class, what it does and who calls it"
 
 ## Where the methods live
 Cancel() and HasOverlap() in which class and why?
 Cancel() => lives in Reservation class so user can cancel it (may be?)
 HasOverlap() => lives in ReservationStore cause there are all reservations that has been done

 ## Activity traces
 Omar R8 15-15 Nov ->  False (no sharing a night) -> Reservation Confirmed -> Confirmation Email Sent! -> Accapted