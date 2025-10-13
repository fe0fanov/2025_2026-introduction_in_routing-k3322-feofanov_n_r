/interface vlan
add name=vlan10 vlan-id=10 interface=ether2
add name=vlan20 vlan-id=20 interface=ether2
/ip address
add address=10.10.0.1/24 interface=vlan10
add address=10.20.0.1/24 interface=vlan20
/ip pool
add name=pool10 ranges=10.10.0.10-10.10.0.254
add name=pool20 ranges=10.20.0.10-10.20.0.254
/ip dhcp-server
add address-pool=pool10 disabled=no interface=vlan10 name=dhcp-server10
add address-pool=pool20 disabled=no interface=vlan20 name=dhcp-server20
/ip dhcp-server network
add address=10.10.0.0/24 gateway=10.10.0.1
add address=10.20.0.0/24 gateway=10.20.0.1
/user
add name=fe0fanov password=1234 group=full
remove admin
/system identity
set name=R01

