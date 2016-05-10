class profile_wls::members () {
  class { '::fmw_domain::domain':
    nodemanagers => [ { "id" => "node1",
                        "listen_address" => '192.168.0.175',
                      },
                      { "id" => "node2",
                        "listen_address" => '192.168.0.176',
                      }],
    servers      =>  [
      { "id"             => "server1",
        "nodemanager"    => "node1",
        "listen_address" => '192.168.0.175',
        "listen_port"    => 8001,
        "arguments"      => "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m"
      },
      { "id"             => "server2",
        "nodemanager"    => "node2",
        "listen_address" => '192.168.0.176',
        "listen_port"    => 8002,
        "arguments"      => "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m"
      },
      ],
    clusters      => [
      { "id"      => "cluster1",
        "members" => ["server1","server2"]
      },
    ],
  }

}




