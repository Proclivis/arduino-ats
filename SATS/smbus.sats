staload "./twi.sats"

datatype smbus_status =
  | SMBusOk of ()
  | SMBusBadLen of ()
  | SMBusNack of ()
  | SMBusOther of ()

datatype smbus_result (a:t@ype) =
  | SMBusData of a
  | SMbusError of smbus_status

fun send_byte (address: uint8, command: uint8) : smbus_status
fun write_byte (address: uint8, command: uint8, data: uint8) : smbus_status
fun write_word (address: uint8, command: uint8, data: uint16) : smbus_status

fun read_byte (address: uint8, command: uint8) : smbus_result (uint8)
fun read_word (address: uint8, command: uint8) : smbus_result (uint16)