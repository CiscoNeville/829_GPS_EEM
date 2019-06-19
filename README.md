# 829_GPS_EEM
Script geofence a Cisco 829 router and disable WiFi if inside geofence

To use: upload the script bistate1.tcl to flash:/ on your 819/829 ISR router. Any Cisco router with embedded GPS will work <br>
register the EEM TCL script with "event manager policy bistate1.tcl <p>

Example:<br>
ISR819# copy ftp://username:password@myftpserver.mydomain.com/bistate1.tcl flash:bistate1.tcl<br>
ISR819# config t<br>
ISR819# no event manager policy bistate1.tcl      <- un-registeres the script if already present<br>
ISR819# event manager policy bistate.tcl<br>

