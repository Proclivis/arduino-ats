#include "config.hats"
#include "{$TOP}/avr_prelude/kernel_staload.hats"
staload "{$TOP}/SATS/arduino.sats"
staload "{$TOP}/SATS/crc.sats"

staload UN = "prelude/SATS/unsafe.sats"

macdef i8(x) = $UN.cast{int8}(,(x))
macdef u8(x) = $UN.cast{uint8}(,(x))
macdef u16(x) = $UN.cast{uint16}(,(x))

extern fun{} n8 (x: uint8): natLt(256) 
implement{} n8 (x)  = $UN.cast{natLt(256)}(x) // Can't go wrong because they are the same size

(* PEC Support *)

%{^
const uint8_t theCrcLookupTable[256] PROGMEM  = { 0, 7, 14, 9, 28, 27, 18, 21,
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

unsigned char
crcLookupTable_read
  (char *T, int index)
{
  return pgm_read_byte(&T[index]) ;
}

%}

abstype
crcLookupTable = ptr

extern
val
theCrcLookupTable: crcLookupTable = "mac#"

extern
fun
crcLookupTable_read
  (crcLookupTable, natLt(256)): uint8 = "mac#"
overload [] with crcLookupTable_read

extern
fun
crcLookupTable_read_uint8
  (crcLookupTable, index: uint8): uint8 = "mac#"
overload [] with crcLookupTable_read_uint8

implement
crcLookupTable_read_uint8
  (T, i) =
  let val i = $UN.cast{natLt(256)}(i) in T[i] end

implement
pec_add(old, new) = theCrcLookupTable[old lxor new]