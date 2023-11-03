{
imports = [
<nixpkgs/nftables>
];

networking.bridges.br0.interfaces = [ "eth1" "eth2" "eth3" "eth4" "eth5" ];
services.dhcpd5.interaces = [ "br0" ] ;
services.dhcpd.interfaces.br0.ranges = {
 start = "192.168.25.100";
 end = "192.168.25.255";
 };
 networking.interfaces.eth1.mtu = 9000;
 networking.interfaces.eth2.mtu = 9000;
 networking.interfaces.eth3.mtu = 9000;
 networking.interfaces.eth4.mtu = 9000;
 networking.interfaces.eth5.mtu = 9000;
 config = {
  nftables = {
    tables = {
      ipv4 = {
        nat = {
          chains = {
            POSTROUTING = {
              rules = [
                {
                  type = "add";
                  rule = {
                      action = "masquerade";
                      interfaces = "eth0";
                      out = "eth1"
                  };

                }
              ];
            };
          };
        };
      };
    };
  };
 };
}
