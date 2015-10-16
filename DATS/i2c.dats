#include "config.hats"
#include "{$TOP}/avr_prelude/kernel_staload.hats"
staload "{$TOP}/SATS/arduino.sats"
staload "{$TOP}/SATS/i2c.sats"
staload "{$TOP}/SATS/crc.sats"

//staload UN = "prelude/SATS/unsafe.sats"
staload "prelude/SATS/unsafe.sats"

macdef i8(x) = cast{int8}(,(x))
macdef u8(x) = cast{uint8}(,(x))
macdef u16(x) = cast{uint16}(,(x))

macdef
ifnerr(x, err, ec, t) =
(
if
(,(err) = ,(t)(0))
then let
  val () = ,(err) := ,(x)
in
  if ,(err) != ,(t)(0) then ,(err) := ,(t)(,(ec))
end // end of [then]
)

macdef err (z, t) = ,(t)(,(z))

fun wa (addr:uint8) : uint8 = addr << 1
fun ra (addr:uint8) : uint8 = (addr << 1) + u8(1)

implement i2c_start () = u8(i2c_start_p())
implement i2c_repeated_start () = u8(i2c_repeated_start_p())
implement i2c_write (b) = u8(i2c_write_p(b))
implement i2c_read (b) = i2c_read_p(i8(b))

implement i2c_read_byte(address: uint8): (uint8, uint8) = let
  var err: uint8 =                       err (0, u8)
  val () = ifnerr(i2c_start(),           err, 1, u8)
  val () = ifnerr(i2c_write(wa address), err, 2, u8)
  val b  =        i2c_read(u8(WITH_NACK))
  val () =        i2c_stop()
  in (err, b) end

implement i2c_read_byte_pec(address: uint8): (uint8, uint8) = let
  var err: uint8 =                         err (0, u8)
  val ()   = ifnerr(i2c_start(),           err, 1, u8)
  val ()   = ifnerr(i2c_write(wa address), err, 2, u8)
  val b    =        i2c_read(u8(WITH_ACK))
  val pec  =        i2c_read(u8(WITH_NACK))
  val ()   =        i2c_stop()
  val err2 = if err = u8(1) then err else if pec = pec_add(pec_add(u8(0), address), b) then u8(0) else u8(1)
  in (err2, b) end

implement i2c_write_byte(address: uint8, data: uint8): uint8 = let
  var err: uint8 =                       err (0, u8)
  val () = ifnerr(i2c_start(),           err, 1, u8)
  val () = ifnerr(i2c_write(wa address), err, 2, u8)
  val () = ifnerr(i2c_write(data),       err, 3, u8)
  val () =        i2c_stop()
  in err end

implement i2c_write_byte_pec(address: uint8, data: uint8): uint8 = let
  var err: uint8 =                                 err (0, u8)
  val pec = pec_add(pec_add(u8(0), address), data)
  val ()  = ifnerr(i2c_start(),                    err, 1, u8)
  val ()  = ifnerr(i2c_write(wa address),          err, 2, u8)
  val ()  = ifnerr(i2c_write(data),                err, 3, u8)
  val ()  = ifnerr(i2c_write(pec),                 err, 3, u8)
  val ()  =        i2c_stop()
  in err end

implement i2c_read_byte_data(address: uint8, command: uint8): (uint8, uint8) = let
  val _ = print! "iirbd "
  var err: uint8 =                       err (0, u8)
  val () = ifnerr(i2c_start(),           err, 1, u8)
  val _ = print! err
  val _ = print! " "
  val () = ifnerr(i2c_write(wa address), err, 2, u8)
  val _ = print! err
  val _ = print! " "
  val () = ifnerr(i2c_write(command),    err, 3, u8)
  val _ = print! err
  val _ = print! " done"
  val () = ifnerr(i2c_start(),           err, 4, u8)  
  val () = ifnerr(i2c_write(ra address), err, 5, u8)
  val b  = if err = u8(0) then i2c_read(u8(WITH_NACK)) else u8(0)
  val () =        i2c_stop()
  in (err, b) end

implement i2c_read_byte_data_pec(address: uint8, command: uint8): (uint8, uint8) = let
  var err: uint8 =                         err (0, u8)
  val ()   = ifnerr(i2c_start(),           err, 1, u8)
  val ()   = ifnerr(i2c_write(wa address), err, 2, u8)
  val ()   = ifnerr(i2c_write(command),    err, 3, u8)
  val ()   = ifnerr(i2c_start(),           err, 4, u8)  
  val ()   = ifnerr(i2c_write(ra address), err, 5, u8)
  val b    = if err = u8(0) then i2c_read(u8(WITH_ACK)) else u8(0)
  val pec  = if err = u8(0) then i2c_read(u8(WITH_NACK)) else u8(0)
  val ()   = i2c_stop()
  val err2 = if err = u8(1) then err else if pec = pec_add(pec_add(pec_add(u8(0), address), command), b) then u8(0) else u8(1)
  in (err2, b) end

implement i2c_write_byte_data(address: uint8, command: uint8, data: uint8): uint8 = let
  var err: uint8 =                       err (0, u8)
  val () = ifnerr(i2c_start(),           err, 1, u8)
  val () = ifnerr(i2c_write(wa address), err, 2, u8)
  val () = ifnerr(i2c_write(command),    err, 3, u8)
  val () = ifnerr(i2c_write(data),       err, 4, u8)
  val () =        i2c_stop()
  in err end

implement i2c_write_byte_data_pec(address: uint8, command: uint8, data: uint8): uint8 = let
  var err: uint8 =                                                    err (0, u8)
  val pec = pec_add(pec_add(pec_add(u8(0), address), command), data)
  val ()  = ifnerr(i2c_start(),                                       err, 1, u8)
  val ()  = ifnerr(i2c_write(wa address),                             err, 2, u8)
  val ()  = ifnerr(i2c_write(command),                                err, 3, u8)
  val ()  = ifnerr(i2c_write(data),                                   err, 4, u8)
  val ()  = ifnerr(i2c_write(pec),                                    err, 3, u8)
  val ()  = i2c_stop()
  in err end

implement i2c_read_word_data(address: uint8, command: uint8): (uint8, uint16) = let
  var err: uint8 =                       err (0, u8)
  val () = ifnerr(i2c_start(),           err, 1, u8)
  val () = ifnerr(i2c_write(wa address), err, 2, u8)
  val () = ifnerr(i2c_write(command),    err, 3, u8)
  val () = ifnerr(i2c_start(),           err, 4, u8)
  val () = ifnerr(i2c_write(ra address), err, 5, u8)
  val b1 = if err = u8(0) then i2c_read(u8(WITH_ACK)) else u8(0)
  val b0 = if err = u8(0) then i2c_read(u8(WITH_NACK)) else u8(0)
  val () = i2c_stop()
  val w  = (u16(b1) << 8) + u16(b0)
  in (err, w) end

implement i2c_read_word_data_pec(address: uint8, command: uint8): (uint8, uint16) = let
  var err: uint8 =                         err (0, u8)
  val ()   = ifnerr(i2c_start(),           err, 1, u8)
  val ()   = ifnerr(i2c_write(wa address), err, 2, u8)
  val ()   = ifnerr(i2c_write(command),    err, 3, u8)
  val ()   = ifnerr(i2c_start(),           err, 4, u8)
  val ()   = ifnerr(i2c_write(ra address), err, 5, u8)
  val b1   = if err = u8(0) then i2c_read(u8(WITH_ACK)) else u8(0)
  val b0   = if err = u8(0) then i2c_read(u8(WITH_ACK)) else u8(0)
  val pec  = if err = u8(0) then i2c_read(u8(WITH_NACK)) else u8(0)
  val ()   = i2c_stop()
  val w    = (u16(b1) << 8) + u16(b0)
  val err2 = if err = u8(1) then err else if pec = pec_add(pec_add(pec_add(pec_add(u8(0), address), command), b1), b0) then u8(0) else u8(1)
  in (err2, w) end

implement i2c_write_word_data(address: uint8, command: uint8, data: uint16): uint8 = let
  var err: uint8 =                                          err (0, u8)
  val () = ifnerr(i2c_start(),                              err, 1, u8)
  val () = ifnerr(i2c_write(wa address),                    err, 2, u8)
  val () = ifnerr(i2c_write(command),                       err, 3, u8)
  val () = ifnerr(i2c_write(u8(data >> 8)),                 err, 4, u8)
  val () = ifnerr(i2c_write(u8(data - ((data >> 8) << 8))), err, 5, u8)
  val () =        i2c_stop()
  in err end

implement i2c_write_word_data_pec(address: uint8, command: uint8, data: uint16): uint8 = let
  var err: uint8 =                                                                            err (0, u8)
  val data0 = u8(data >> 8)
  val data1 = u8(data - ((data >> 8) << 8))
  val pec = pec_add(pec_add(pec_add(pec_add(u8(0), address), command), data0), data1)
  val ()  = ifnerr(i2c_start(),                                                               err, 1, u8)
  val ()  = ifnerr(i2c_write(wa address),                                                     err, 2, u8)
  val ()  = ifnerr(i2c_write(command),                                                        err, 3, u8)
  val ()  = ifnerr(i2c_write(data0),                                                          err, 4, u8)
  val ()  = ifnerr(i2c_write(data1),                                                          err, 5, u8)
  val ()  = ifnerr(i2c_write(pec),                                                            err, 3, u8)
  val ()  = i2c_stop()
  in err end