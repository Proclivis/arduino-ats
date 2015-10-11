%{#
#include "lti2c.h"
%}

#define QUIKEVAL_GPIO 9 
#define QUIKEVAL_CS SS 
#define QUIKEVAL_MUX_MODE_PIN 8
#define READ_TIMEOUT  20
#define MISO_TIMEOUT  1000

typedef pin_type = natLt(256)

macdef SS = $extval(pin_type, "SS")
macdef MOSI = $extval(pin_type, "MOSI")
macdef MISO = $extval(pin_type, "MISO")
macdef MISO = $extval(pin_type, "SCK")
macdef WITH_ACK = $extval(int8, "WITH_ACK")
macdef WITH_NACK = $extval(int8, "WITH_NACK")

(* PEC *)
fun pec_add (old: uint8, new: uint8): uint8

(* External Primative Commands *)
fun i2c_set_frequency                  (uint16)                              : void   = "mac#i2c_set_frequency"
fun i2c_enable                         ()                                    : void   = "mac#i2c_enable"
fun i2c_start_p                        ()                                    : int8   = "mac#i2c_start"
fun i2c_repeated_start_p               ()                                    : int8   = "mac#i2c_repeated_start"
fun i2c_stop                           ()                                    : void   = "mac#i2c_stop"
fun i2c_write_p                        (uint8)                               : int8   = "mac#i2c_write"
fun i2c_read_p                         (int8)                                : uint8  = "mac#i2c_read"
fun i2c_poll_p                         (uint8)                               : int8   = "mac#i2c_poll"

(* External Block Comamnds *)
fun i2c_read_block_data_with_command   (uint8, uint8, uint8, cPtr0(uint8))   : int8   = "mac#"
fun i2c_read_block_data                (uint8, uint8, cPtr0(uint8))          : int8   = "mac#"
fun i2c_write_block_data               (uint8, uint8, uint8, cPtr0(uint8))   : int8   = "mac#"
fun i2c_two_byte_command_read_block    (uint8, uint16, uint8, cPtr0(uint8))  : int8   = "mac#"

(* ATS Primative Commands *)
//fun i2c_set_frequency                  (uint16)                              : void
//fun i2c_enable                         ()                                    : void
fun i2c_start                          ()                                    : uint8
fun i2c_repeated_start                 ()                                    : uint8
fun i2c_write                          (uint8)                               : uint8
fun i2c_read                           (uint8)                               : uint8

(* ATS Composite Commands *)

fun i2c_read_byte                      (uint8)                               : (uint8, uint8)
fun i2c_write_byte                     (uint8, uint8)                        : uint8
fun i2c_read_byte_data                 (uint8, uint8)                        : (uint8, uint8)
fun i2c_write_byte_data                (uint8, uint8, uint8)                 : uint8
fun i2c_read_word_data                 (uint8, uint8)                        : (uint8, uint16)
fun i2c_write_word_data                (uint8, uint8, uint16)                : uint8

fun i2c_read_byte_pec                  (uint8)                               : (uint8, uint8)
fun i2c_write_byte_pec                 (uint8, uint8)                        : uint8
fun i2c_read_byte_data_pec             (uint8, uint8)                        : (uint8, uint8)
fun i2c_write_byte_data_pec            (uint8, uint8, uint8)                 : uint8
fun i2c_read_word_data_pec             (uint8, uint8)                        : (uint8, uint16)
fun i2c_write_word_data_pec            (uint8, uint8, uint16)                : uint8
