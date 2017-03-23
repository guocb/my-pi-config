IPT=/sbin/iptables
$IPT -F

$IPT -P INPUT DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT DROP

echo NAT
$IPT -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
$IPT -A FORWARD -i wlan0 -o eth0 -j ACCEPT
$IPT -t nat -A POSTROUTING -o eth0 -j MASQUERADE

echo Allow incoming ssh, http, https
$IPT -A INPUT -i eth0 -p tcp -m multiport --dports 22222,80,443 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -o eth0 -p tcp -m multiport --sports 22222,80,443 -m state --state ESTABLISHED -j ACCEPT

echo Allow outgoing SSH,http,telnet,https
$IPT -A OUTPUT -o eth0 -p tcp -m multiport --dports 21,22,80,443 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT -i eth0 -p tcp -m multiport --sports 21,22,80,443 -m state --state ESTABLISHED -j ACCEPT

echo Ping from inside to outside
$IPT -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
$IPT -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT

echo Allow loopback access
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT

echo Allow outbound DNS
$IPT -A OUTPUT -p udp -o eth0 --dport 53 -j ACCEPT
$IPT -A INPUT -p udp -i eth0 --sport 53 -j ACCEPT
$IPT -A OUTPUT -p tcp -o eth0 --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT  -p tcp -i eth0 --sport 53 -m state --state ESTABLISHED     -j ACCEPT

echo "Allow outgoing icmp connections (pings,...)"
$IPT -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$IPT -A INPUT  -p icmp -m state --state ESTABLISHED,RELATED     -j ACCEPT

echo "Allow outgoing connections to port 123 (ntp syncs)"
$IPT -A OUTPUT -p udp --dport 123 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT  -p udp --sport 123 -m state --state ESTABLISHED     -j ACCEPT

echo Prevent DoS attack
$IPT -A INPUT -i eth0 -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT

echo Log before dropping
$IPT -A INPUT  -j LOG  -m limit --limit 12/min --log-level 4 --log-prefix 'IP INPUT drop: '
$IPT -A INPUT  -j DROP

$IPT -A OUTPUT -j LOG  -m limit --limit 12/min --log-level 4 --log-prefix 'IP OUTPUT drop: '
$IPT -A OUTPUT -j DROP

