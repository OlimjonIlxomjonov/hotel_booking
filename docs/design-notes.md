# PO3 desing notes
## Why desing before code
"Low level desing descides what should be in that class, what it does and who calls it"
 
 ## Where the methods live
 Cancel() and HasOverlap() in which class and why?
 Cancel() => lives in Reservation class so user can cancel it (may be?)
 HasOverlap() => lives in ReservationStore cause there are all reservations that has been done

 ## Activity traces
 Omar R8 15-15 Nov ->  False (no sharing a night) -> Reservation Confirmed -> Confirmation Email Sent! -> Accapted


 # P04 Design Notes
 ## Refactoring
 Three of the classes should be refcatored: EmailSender to EmailNotificationsender `cause The name changes; every booking gives the same result. Move DateRange into its own file reason: The code is in a different place; it does the same thing.Make BookingService accept an interface instead of a concrete class reason: The demo still prints the same nine lines. Also there are 2 Classes that won't be refactored they are Fix the race so Omar gets Unavailable, and Add SMS confirmations.