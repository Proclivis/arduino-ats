%{#
#include "LT_I2C.h"
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

fun i2c_set_frequency                  (uint16)                              : void   = "mac#"
fun i2c_read_byte                      (uint8, cPtr0(uint8))                 : int8   = "mac#"
fun i2c_write_byte                     (uint8, uint8)                        : int8   = "mac#"
fun i2c_read_byte_data                 (uint8, uint8, cPtr0(uint8))          : int8   = "mac#"
fun i2c_write_byte_data                (uint8, uint8, uint8)                 : int8   = "mac#"
fun i2c_read_word_data                 (uint8, uint8, cPtr0(uint16))         : int8   = "mac#"
fun i2c_write_word_data                (uint8, uint8, uint16)                : int8   = "mac#"
fun i2c_read_block_data_with_command   (uint8, uint8, uint8, cPtr0(uint8))   : int8   = "mac#"
fun i2c_read_block_data                (uint8, uint8, cPtr0(uint8))          : int8   = "mac#"
fun i2c_write_block_data               (uint8, uint8, uint8, cPtr0(uint8))   : int8   = "mac#"
fun i2c_two_byte_command_read_block    (uint8, uint16, uint8, cPtr0(uint8))  : int8   = "mac#"
fun i2c_enable                         ()                                    : void   = "mac#"
fun i2c_start                          ()                                    : int8   = "mac#"
fun i2c_repeated_start                 ()                                    : int8   = "mac#"
fun i2c_stop                           ()                                    : void   = "mac#"
fun i2c_write                          (uint8)                               : int8   = "mac#"
fun i2c_read                           (int8)                                : uint8  = "mac#"
fun i2c_poll                           (uint8)                               : int8   = "mac#"
fun quikeval_I2C_init                  ()                                    : void   = "mac#"
fun quikeval_I2C_connect               ()                                    : void   = "mac#"

fun twiddle_stop                       ()                                    : void   = "mac#"  