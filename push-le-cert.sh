#!/usr/bin/expect
# Add arguments for config
# WatchGuard Proxy Cert+Key import script - Kevin Schley
# 
# Credits:
# https://www.boc.de/watchguard-info-portal/2016/08/letsencrypt-zertifikat-als-proxy-zertifikat-auf-watchguard-firebox/
# https://www.boc.de/watchguard-info-portal/2016/06/reboot-der-watchguard-per-script/

set firebox [lindex $argv 0] ;	# WatchGuard IP
set fbusername [lindex $argv 1];			# Username (need device admin)
set fbpassword [lindex $argv 2]; 	# Password for admin user
set certdir [lindex $argv 3];     # Certificat directory
set cert [exec tail -n +2 $certdir/cert.cer | head -n -1]
set key [exec tail -n +2 $certdir/cert.key | head -n -1]

spawn ssh $fbusername@$firebox -p 4118

# accept SSH key verification at first login.

set logged_in 0
 while {!$logged_in} {
 expect timeout {
 } "Are you sure you want to continue connecting (yes/no)? " {
 exp_send "yes\r"
 } "\[Pp\]assword*" {
 exp_send "$fbpassword\r"
 } -re "WG.*(#|>)" {
 set logged_in 1
 }
 }

# Issue import command and disconnect SSH connection!

set timeout 20
 exp_send "import certificate proxy-server from console\r"
 expect timeout {
 } "paste certificate below, then ^D to complete; or ^C to abort" {
exp_send "
-----BEGIN CERTIFICATE-----
"
exp_send "$cert"
exp_send "
-----END CERTIFICATE-----
\r"

exp_send "
-----BEGIN RSA PRIVATE KEY-----
"
exp_send "$key"
exp_send "
-----END RSA PRIVATE KEY-----
\r"


 }
 send "\x04"
 exp_send "exit\r"
 expect -re "WG.*(#|>)"
 exp_close
 exp_wait

