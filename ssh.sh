#!/usr/bin/expect -f
set timeout 30

#example of getting arguments passed from command line..
#not necessarily the best practice for passwords though...
set server [lindex $argv 0]
set user [lindex $argv 1]
set pass [lindex $argv 2]

# connect to server via ssh, login, and su to root
send_user "connecting to $server\n"
spawn ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $user@$server

#login handles cases:
#   login with keys (no user/pass)
#   user/pass
#   login with keys (first time verification)
expect {
  "> " { }
  "$ " { }
  "assword: " { 
        send "$pass\n" 
        expect {
          "> " { }
          "$ " { }
        }
  }
  "(yes/no)? " { 
        send "yes\n"
        expect {
          "> " { }
          "$ " { }
        }
  }
  default {
        send_user "Login failed\n"
        exit 1
  }
}

#example command
send "shutdown -h now\n"

expect {
    "> " {}
    default {}
}

#login out
send_user "finished\n"
exit 0
