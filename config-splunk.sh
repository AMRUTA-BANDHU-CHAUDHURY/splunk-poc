#!/bin/bash
logfile=/tmp/setup.log
echo "START" > logfile
exec > $logfile 2>&1  # Log stdout and std to logfile in /tmp

# This script installs and configures the Splunk Host

SPLUNKPW='TempPW4_Splunk##'
# This temporary. PW will be fetched from KMS
# See https://blog.fugue.co/2015-04-21-aws-kms-secrets.html


Check for root
[ "$(id -u)" -ne 0 ] && echo "Incorrect Permissions - Run this script as root" && exit 1

TIMESTAMP=$(date)

echo; echo "== Update System"
yum -y update

echo; echo "== Download Splunk"
wget -q -O /tmp/splunk-6.6.1-aeae3fe0c5af-linux-2.6-x86_64.rpm 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=6.6.1&product=splunk&filename=splunk-6.6.1-aeae3fe0c5af-linux-2.6-x86_64.rpm&wget=true'

echo; echo "== Download the Splunk GPG Public Key File"
wget -q -O /tmp/SplunkRPMKey 'https://docs.splunk.com/images/6/6b/SplunkPGPKey.pub'

echo; echo "== Install the GPG Key"
rpm --import /tmp/SplunkRPMKey

echo; echo "== Verify the Package Signature"
OUTPUT=$(rpm -K /tmp/splunk-* | grep "OK" | wc -c)
if [ $OUTPUT == 0 ]
then
echo " "
echo "*****ERROR - Invalid RPM Signature.  Installation will abort."
exit 1
fi

echo; echo "== Install Splunk"
rpm -i /tmp/splunk-*.rpm

echo; echo "== Set Environment Variables"
export SPLUNK_HOME=/opt/splunk >> $HOME/.bash_profile
export PATH=$SPLUNK_HOME/bin:$PATH >> $HOME/.bash_profile
source ~/.bashrc

echo; echo "== Start Splunk"
$SPLUNK_HOME/bin/splunk start --accept-license
echo; echo "== Enable start at boot"
$SPLUNK_HOME/bin/splunk enable boot-start

echo; echo "== Change Default Password"
$SPLUNK_HOME/bin/splunk edit user admin -password $SPLUNKPW -role admin \
-auth admin:changeme

echo; echo "== Configure Splunk Indexer to monitor its own Files"
$SPLUNK_HOME/bin/splunk add monitor /var/log/secure -auth admin:$SPLUNKPW

echo; echo "== Enable Splunk to Recieve Data from Universal Forwarder"
$SPLUNK_HOME/bin/splunk enable listen 9997 -auth admin:$SPLUNKPW

# Enable HTTPS & Restart Splunk
# TODO Get a Certificate from https://letsencrypt.org/
# TODO http://docs.splunk.com/Documentation/Splunk/6.6.0/Security/Getthird-partycertificatesforSplunkWeb
# TODO Configure an Elastic IP and/or DYNDNS with hostname
cat << 'EOF' > /opt/splunk/etc/system/local/web.conf
[settings]
enableSplunkWebSSL = true
EOF
echo; echo "== Restart Splunk"
$SPLUNK_HOME/bin/splunk restart

echo; echo "== Display Splunk Web UI URL"
PUBLIC_IP=`wget http://ipecho.net/plain -O - -q ; echo`
echo "Access Splunk using =====> https://"$PUBLIC_IP":8000" > /tmp/details.txt
echo
cat /tmp/details.txt

echo; echo "== SCRIPT COMPLETE"
echo; echo "== $0 has completed"
