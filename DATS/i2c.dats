#include "config.hats"
#include "{$TOP}/avr_prelude/kernel_staload.hats"
staload "{$TOP}/SATS/arduino.sats"
staload "{$TOP}/SATS/i2c.sats"

//staload UN = "prelude/SATS/unsafe.sats"
staload "prelude/SATS/unsafe.sats"

macdef i8(x) = cast{int8}(,(x))
macdef u8(x) = cast{uint8}(,(x))
macdef u16(x) = cast{uint16}(,(x))

extern fun{} n8 (x: uint8): natLt(256) 
implement{} n8 (x)  = cast{natLt(256)}(x) // Can't go wrong because they are the same size

(* PEC Support *)

%{^
const uint8_t crcLookupTable[256] PROGMEM  = { 0, 7, 14, 9, 28, 27, 18, 21,
                                       56, 63, 54, 49, 36, 35, 42, 45,
                                       112, 119, 126, 121, 108, 107, 98, 101,
                                       72, 79, 70, 65, 84, 83, 90, 93,
                                       224, 231, 238, 233, 252, 251, 242, 245,
                                       216, 223, 214, 209, 196, 195, 202, 205,
                                       144, 151, 158, 153, 140, 139, 130, 133,
                                       168, 175, 166, 161, 180, 179, 186, 189,
                                       199, 192, 201, 206, 219, 220, 213, 210,
                                       255, 248, 241, 246, 227, 228, 237, 234,
                                       183, 176, 185, 190, 171, 172, 165, 162,
                                       143, 136, 129, 134, 147, 148, 157, 154,
                                       39, 32, 41, 46, 59, 60, 53, 50,
                                       31, 24, 17, 22, 3, 4, 13, 10,
                                       87, 80, 89, 94, 75, 76, 69, 66,
                                       111, 104, 97, 102, 115, 116, 125, 122,
                                       137, 142, 135, 128, 149, 146, 155, 156,
                                       177, 182, 191, 184, 173, 170, 163, 164,
                                       249, 254, 247, 240, 229, 226, 235, 236,
                                       193, 198, 207, 200, 221, 218, 211, 212,
                                       105, 110, 103, 96, 117, 114, 123, 124,
                                       81, 86, 95, 88, 77, 74, 67, 68,
                                       25, 30, 23, 16, 5, 2, 11, 12,
                                       33, 38, 47, 40, 61, 58, 51, 52,
                                       78, 73, 64, 71, 82, 85, 92, 91,
                                       118, 113, 120, 127, 106, 109, 100, 99,
                                       62, 57, 48, 55, 34, 37, 44, 43,
                                       6, 1, 8, 15, 26, 29, 20, 19,
                                       174, 169, 160, 167, 178, 181, 188, 187,
                                       150, 145, 152, 159, 138, 141, 132, 131,
                                       222, 217, 208, 215, 194, 197, 204, 203,
                                       230, 225, 232, 239, 250, 253, 244, 243
                                     };
%}

macdef crcLookupTable =
  $extval(arrayref(uint8,256),"crcLookupTable")

implement pec_add (old, new) = crcLookupTable[n8(old lxor new)]

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
  var err: uint8 =                       err (0, u8)
  val () = ifnerr(i2c_start(),           err, 1, u8)
  val () = ifnerr(i2c_write(wa address), err, 2, u8)
  val () = ifnerr(i2c_write(command),    err, 3, u8)
  val () = ifnerr(i2c_start(),           err, 4, u8)  
  val () = ifnerr(i2c_write(ra address), err, 5, u8)
  val b  =        i2c_read(u8(WITH_NACK))
  val () =        i2c_stop()
  in (err, b) end

implement i2c_read_byte_data_pec(address: uint8, command: uint8): (uint8, uint8) = let
  var err: uint8 =                         err (0, u8)
  val ()   = ifnerr(i2c_start(),           err, 1, u8)
  val ()   = ifnerr(i2c_write(wa address), err, 2, u8)
  val ()   = ifnerr(i2c_write(command),    err, 3, u8)
  val ()   = ifnerr(i2c_start(),           err, 4, u8)  
  val ()   = ifnerr(i2c_write(ra address), err, 5, u8)
  val b    = i2c_read(u8(WITH_ACK))
  val pec  = i2c_read(u8(WITH_NACK))
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
  val b1 = i2c_read(u8(WITH_ACK))
  val b0 = i2c_read(u8(WITH_NACK))
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
  val b1   = i2c_read(u8(WITH_ACK))
  val b0   = i2c_read(u8(WITH_ACK))
  val pec  = i2c_read(u8(WITH_NACK))
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