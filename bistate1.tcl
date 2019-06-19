::cisco::eem::event_register_timer cron name EVERY1MIN cron_entry "* * * * *"
# Geofence Script for BiState
# Written by Neville Aga (neaga@cisco.com) and Jeff Humphries (jehumphr@cisco.com) - May 2019
# Written for Metrostlouis.org
#
# This script will poll the GPS location of an 819, 829 or 889 ISR Cisco Router
# Upon coming within 1500 feet of a target location it will disable the 2.4GHz radio on the Router
#
# Set script variables below. This only works in the US Northern Hemisphere (N, W coordinates) 
set TARGET_LATITUDE 35.241
set TARGET_LONGITUDE 97.449
set GEOFENCE_DISTANCE 1000
############# Do Not Edit below this line #############


#Norman North HS = 35.241, 97.449
#My house = 35.232, 97.501
#GEOFENCE_DISTANCE is the distance in feet where if I am within, take action

#when I want to move it back to timer based

#for debugging have below as 1st line of script
#::cisco::eem::event_register_none 

namespace import ::cisco::eem::*
namespace import ::cisco::lib::*

array set arr_einfo [event_reqinfo]


if [catch {cli_open} result] {
    error $result $errorInfo
} else {
    array set cli1 $result
}

action_syslog msg "TCL5 script is writing GPS location to file"


if [catch {cli_exec $cli1(fd) "enable"} _cli_result] {
    error $_cli_result $errorInfo
}

#if [catch {cli_exec $cli1(fd) "show clock"} _cli_result] {
#    error $_cli_result $errorInfo
#} 
#action_syslog msg "$_cli_result"



if [catch {cli_exec $cli1(fd) "show cellular 0 gps"} _cli_result] {
    error $_cli_result $errorInfo
}

action_syslog msg "$_cli_result"

#get Lat and Long into variables as decimal degrees
#This is so, so very bad, but TCL is splitting the sting by every whitespace, not by each CRLF.
#The latitude coordinates are in 13,15,17,19 and longitude are in 21,23,25,27
#However, that is dependent on having status "GPS Status: GPS coordinates acquired" or else the count will be off
#Will need to include error checking here in the future depending on production use

set LAT1 [lindex $_cli_result 13]
set LAT2 [lindex $_cli_result 15]
set LAT3 [lindex $_cli_result 17]
set LAT4 [lindex $_cli_result 19]
set LAT [expr $LAT1 + $LAT2 / 60.0 + $LAT3 / 3600.0]

set LON1 [lindex $_cli_result 21]
set LON2 [lindex $_cli_result 23]
set LON3 [lindex $_cli_result 25]
set LON4 [lindex $_cli_result 27]
set LON [expr $LON1 + $LON2 / 60.0 + $LON3 / 3600.0]

action_syslog msg "Current Location is $LAT $LON" 
#Currently I am ignoring South and East coordinates.  Want to use this script outside the USA? Modify it yourself


#Compute distance from target area
set DELTA_LAT [expr $LAT - $TARGET_LATITUDE]
set DELTA_LON [expr $LON - $TARGET_LONGITUDE]
#action_syslog msg "Current DELTA_LAT is $DELTA_LAT" 
#action_syslog msg "Current DELTA_LON is $DELTA_LON" 

#make both deltas positive and just add the 2 damn distances together
if {$DELTA_LAT < 0.0} {set DELTA_LAT [expr -1.0 * $DELTA_LAT] } else {}
if {$DELTA_LON < 0.0} {set DELTA_LON [expr -1.0 * $DELTA_LON]} else {}

set DELTA [expr $DELTA_LAT + $DELTA_LON]
set DELTA [expr $DELTA * 70 * 5280]


##Unbelievably, the below is too complex for Cisco EEM. Have to dumb it down
##This will get delta distance in feet
##set DELTA [(($DELTA_LAT^2 + $DELTA_LON^2)^.5)*70*5280]
#set DELTA1 [expr {$DELTA_LAT * $DELTA_LAT}]
#set DELTA2 [expr {$DELTA_LON * $DELTA_LON}]
#set DELTASQ [expr {$DELTA1 + $DELTA2}]
#action_syslog msg "Current DELTASQ  is $DELTASQ" 
#
#OK, now comes the most ridiculous part imaginable. The Cisco implementation of TCL in EEM does not support the command sqrt()
#set DELTA 0
#while {$DELTA < $DELTASQ} {
#    if {[expr {$DELTA * $DELTA}] > $DELTASQ} break
#    set DELTA [expr {$DELTA + 0.01}]
#} 

action_syslog msg "Current distance delta in feet is $DELTA" 



#Check distance. Am I within the geofence of interest?

if { $DELTA < $GEOFENCE_DISTANCE } {

action_syslog msg "I am inside geofence area" 
action_syslog msg "Shutting interface Dot11 Radio 0 (2.4GHz)" 

if [catch {cli_exec $cli1(fd) "service-module wlan-ap 0 session"} _cli_result] {
    error $_cli_result $errorInfo
}

#if [catch {cli_exec $cli1(fd) "enable"} _cli_result] {
#    error $_cli_result $errorInfo
#}
#
#if [catch {cli_exec $cli1(fd) "config t"} _cli_result] {
#    error $_cli_result $errorInfo
#}
#
#if [catch {cli_exec $cli1(fd) "interface dot11Radio 0"} _cli_result] {
#    error $_cli_result $errorInfo
#}
#
#if [catch {cli_exec $cli1(fd) "shutdown"} _cli_result] {
#    error $_cli_result $errorInfo
#}
#
#if [catch {cli_exec $cli1(fd) "end"} _cli_result] {
#    error $_cli_result $errorInfo
#}
     } else {

action_syslog msg "I am outside geofence area" 
action_syslog msg "Brining up interface Dot11 Radio 0 (2.4GHz)" 

if [catch {cli_exec $cli1(fd) "service-module wlan-ap 0 session"} _cli_result] {
    error $_cli_result $errorInfo
}

if [catch {cli_exec $cli1(fd) "enable"} _cli_result] {
    error $_cli_result $errorInfo
}

if [catch {cli_exec $cli1(fd) "config t"} _cli_result] {
    error $_cli_result $errorInfo
}

if [catch {cli_exec $cli1(fd) "interface dot11Radio 0"} _cli_result] {
    error $_cli_result $errorInfo
}

if [catch {cli_exec $cli1(fd) "no shutdown"} _cli_result] {
    error $_cli_result $errorInfo
}

if [catch {cli_exec $cli1(fd) "end"} _cli_result] {
    error $_cli_result $errorInfo
}
 
    
    
    }







#set RESULT [split _cli_result "L"]
#set ELEMENTS [llength RESULT]
#action_syslog msg "number of elements in RESULT list is $ELEMENTS"





#if [catch {cli_exec $cli1(fd) "show cellular 0 gps | append flash:SHOW_GPS.TXT"} _cli_result] {
#    error $_cli_result $errorInfo
#}


after 1000
#if [catch {cli_exec $cli1(fd) "copy flash:SHOW_GPS.TXT syslog:"} _cli_result] {
#    error $_cli_result $errorInfo
#}














# Close open cli before exit.
catch {cli_close $cli1(fd) $cli1(tty_id)} result


