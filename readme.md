# Splunk POC
Demonstration of using AWS the Command Line Interface to provision a Splunk Indexer
and a Linux Instance with the Splunk Forwarder.

## Instructions

To use the demonstration environment in AWS, enter the following command:
```
./setup.sh # Set up the environment
```

To use it you must [configure your AWS Profile Parameters](../master/doc/configuration.md)
in **setup.conf**.

`./teardown.sh` will delete all EC2 instances, the VPC, and other objects created
by the aws-setup script with the help of the .log files created during setup.

## Description
This proof-of-concept creates two EC2 instances in a dedicated VPC, complete
with security groups, routing and everything necessary to deploy via script.

One instance is configured as a Splunk Indexer and Search Head.  The other instance
is a typical Linux system with the splunk forwarder installed and configured to
send data to the indexer across the local subnet.

The script detects your external IP address and restricts inbound access from only
that address to port 22 (SSH) or port 8000 (HTTPS to Splunk).

At the end of the script specific details on how to SSH and connect to the Splunk
Web UI are presented based on your setup.conf.
