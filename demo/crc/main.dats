//#define ATS_DYNLOADFLAG 1

#include
"share/atspre_staload.hats"

staload "prelude/SATS/bool.sats"
staload "prelude/SATS/unsafe.sats"

staload "/home/mike/linti/libs/arduino-ats/SATS/crc.sats"

macdef i8(x)  = cast{int8}(,(x))
macdef u8(x)  = cast{uint8}(,(x))
macdef u16(x) = cast{uint16}(,(x))

extern fun{} n7 (x: uint8): natLte(127)
implement{} n7 (x)  = cast{natLte(127)}(x land u8(0x7F)) // This sets a specific masking policy

extern fun{} n8 (x: uint8): natLt(256) 
implement{} n8 (x)  = cast{natLt(256)}(x) // Can't go wrong because they are the same size

dynload "/home/mike/linti/libs/arduino-ats/DATS/crc.dats"

val ZERO = u8(0)

implement main0 () = {
    
  val pec = pec_add(ZERO, u8(4))
  val () = print! pec
  val () = print! "\n"

}