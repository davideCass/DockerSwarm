#!/usr/bin/env tclsh
#package require Expect
#spawn ssh vagrant@swarm-2 "sh /home/asw/_shared/scripts/create-overrideconf.sh"
# Time out (in seconds) for the expect commands
sudo su
expect -c 'spawn ssh vagrant@swarm-2 "sh /home/asw/_shared/scripts/create-overrideconf.sh"; set timeout 0.1; expect "Are you sure you want to continue connecting (yes/no)?"; send "yes\r"; set timeout 5; expect "password:"; send "vagrant\r"; interact'	  
#expect "Are you sure you want to continue connecting (yes/no)?" { send "yes\r" }
#expect "Please type 'yes' or 'no':" { send "yes\r" }
#expect "password:" { send "vagrant\r" }
#interact
#spawn ssh vagrant@swarm-3 
# Time out (in seconds) for the expect commands
#set timeout 1
#expect "Are you sure you want to continue connecting (yes/no)?" { send "yes\r" }
#expect "Please type 'yes' or 'no':" { send "yes\r" }
#expect "password:" { send "vagrant\r" }
#interact