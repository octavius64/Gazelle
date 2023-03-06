<?
//Useful: http://www.robtex.com/cnet/
$AllowedProxies = array(
	//Opera Turbo (may include Opera-owned IP addresses that aren't used for Turbo, but shouldn't run much risk of exploitation)
	'64.255.180.*', //Norway
	'64.255.164.*', //Norway
	'80.239.242.*', //Poland
	'80.239.243.*', //Poland
	'91.203.96.*', //Norway
	'94.246.126.*', //Norway
	'94.246.127.*', //Norway
	'195.189.142.*', //Norway
	'195.189.143.*', //Norway
);

function cidrMatch($ip, $range) {
    list ($subnet, $bits) = explode('/', $range);
    if ($bits === null) {
        $bits = 32;
    }
    $ip = ip2long($ip);
    $subnet = ip2long($subnet);
    $mask = -1 << (32 - $bits);
    $subnet &= $mask; # nb: in case the supplied subnet wasn't correctly aligned
    return ($ip & $mask) == $subnet;
}

function proxyCheck($IP) {
	global $AllowedProxySubnets;
	foreach ($AllowedProxySubnets as $ipSubnet) {
		if (cidrMatch($IP, $ipSubnet)) {
			return true;
		}
	}

	return false;
}
