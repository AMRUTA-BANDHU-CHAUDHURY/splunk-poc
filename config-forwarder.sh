#!/bin/bash
logfile=/tmp/setup.log
echo "START" > logfile
exec > $logfile 2>&1  # Log stdout and std to logfile in /tmp

# Script to configure typical Linux host after launchtime

# Check for root
[ "$(id -u)" -ne 0 ] && echo "Incorrect Permissions - Run this script as root" && exit 1

TIMESTAMP=$(date)

echo; echo "== Install Updates"
yum -y update

echo; echo "== Turn on Process Accounting"
chkconfig psacct on

echo; echo "== Install tcpdump"
yum -y install tcpdump    # tcpdump is helpful for observing malicious network behavior for poc
                          # not typically part of system config

echo; echo "== Install the Splunk Forwarder"
echo "START OF SPLUNK FORWARDER INSTALLATION"
cd /tmp/
wget -q -O install-splunkforwarder-linux.sh \
  'https://raw.githubusercontent.com/Resistor52/6100/master/install/install-splunkforwarder-linux.sh' \
  > /dev/null
chmod +x install-splunkforwarder-linux.sh
./install-splunkforwarder-linux.sh > /dev/null

echo; echo "== SCRIPT COMPLETE"
echo; echo "== $0 has completed"
