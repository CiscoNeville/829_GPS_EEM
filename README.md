# 829_GPS_EEM
Script geofence a Cisco 829 router and disable WiFi if inside geofence

To use: upload the script bistate1.tcl to flash:/ on your 819/829 ISR router
any Cisco router with embedded GPS will work
register the EEM TCL script with "event manager policy bistate1.tcl

Example:
ISR819# copy ftp://username:password@myftpserver.mydomain.com/bistate1.tcl flash:bistate1.tcl
ISR819# config t
ISR819# no event manager policy bistate1.tcl      <- un-registeres the script if already present
ISR819# event manager policy bistate.tcl


