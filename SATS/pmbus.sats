staload "./smbus.sats"

fun set_page (address: uint8) : smbus_status
fun get_page (address: uint8) : (smbus_status, uint8)