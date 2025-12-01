#!/bin/sh
ip route del default via 10.20.30.1 dev eth0
udhcpc -i eth1
