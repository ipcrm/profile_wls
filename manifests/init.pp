class profile_wls (
  $jdk_home  = '/usr/java/jdk1.8.0_45',
  $version   = 1221,
  $filename  = 'fmw_12.2.1.0.0_wls.jar',
  $orabase   = '/opt/oracle',
  $mw_home   = '/opt/oracle/middleware12c',
  $wl_home   = '/opt/oracle/middleware12c/wlserver',
  $os_user   = 'oracle',
  $os_group  = 'dba',
  $dwnld_dir = '/var/tmp',
  $src_dir   = '/var/tmp',
  $log_dir   = '/var/tmp',
  $address   = $::ipaddress,
  $servers   = {},
){

  Sysctl <||> -> Class['limits'] -> Group[$os_group] -> User[$os_user] -> Class['::orawls::urandomfix'] -> Class['orawls::weblogic']

  sysctl { 'kernel.msgmnb':                 ensure => 'present', permanent => 'yes', value => '65536',}
  sysctl { 'kernel.msgmax':                 ensure => 'present', permanent => 'yes', value => '65536',}
  sysctl { 'kernel.shmmax':                 ensure => 'present', permanent => 'yes', value => '2147483648',}
  sysctl { 'kernel.shmall':                 ensure => 'present', permanent => 'yes', value => '2097152',}
  sysctl { 'fs.file-max':                   ensure => 'present', permanent => 'yes', value => '344030',}
  sysctl { 'net.ipv4.tcp_keepalive_time':   ensure => 'present', permanent => 'yes', value => '1800',}
  sysctl { 'net.ipv4.tcp_keepalive_intvl':  ensure => 'present', permanent => 'yes', value => '30',}
  sysctl { 'net.ipv4.tcp_keepalive_probes': ensure => 'present', permanent => 'yes', value => '5',}
  sysctl { 'net.ipv4.tcp_fin_timeout':      ensure => 'present', permanent => 'yes', value => '30',}
  class { '::limits':
    config => {
      '*' => {
        'nofile' => {
          soft => '2048',
          hard => '8192',
        },
      },
      'oracle'  => {
        'nofile' => {
          soft => '65535',
          hard => '65535',
        },
      'nproc'   => { soft => '2048'   , hard => '2048',   },
      'memlock' => {
        soft => '1048576',
        hard => '1048576',
        },
      },
    },
    use_hiera => false,
  }

  group { $os_group:
    ensure => present,
  }

  user { $os_user:
    ensure     => present,
    groups     => 'dba',
    shell      => '/bin/bash',
    password   => '$1$l2/BjYjS$Y7pLUyyh5i1eqhCyelAiF.',
    home       => "/home/${os_user}",
    comment    => 'Oracle user created by Puppet',
    managehome => true,
    require    => Group[$os_group],
  }

  include ::orawls::urandomfix

  wls_setting { 'default':
    user                         => 'oracle',
    weblogic_home_dir            => $wl_home,
    connect_url                  => "t3://localhost:7001",
    weblogic_user                => 'weblogic',
    weblogic_password            => 'weblogic1',
    use_default_value_when_empty => true
  }

  class{'::orawls::weblogic':
    version              => $version,
    filename             => $filename,
    jdk_home_dir         => $jdk_home,
    oracle_base_home_dir => $orabase,
    middleware_home_dir  => $mw_home,
    weblogic_home_dir    => $wl_home,
    os_user              => $os_user,
    os_group             => $os_group,
    download_dir         => $dwnld_dir,
    source               => $src_dir,
    log_output           => true,
  }

  orawls::domain { 'wlsDomain12c':
    version                     => $version,
    weblogic_home_dir           => $wl_home,
    middleware_home_dir         => $mw_home,
    jdk_home_dir                => $jdk_home,
    domain_template             => 'standard',
    domain_name                 => 'Wls12c',
    development_mode            => false,
    adminserver_name            => 'AdminServer',
    adminserver_address         => $address,
    adminserver_port            => 7001,
    nodemanager_secure_listener => true,
    nodemanager_port            => 5556,
    java_arguments              => {},
    weblogic_user               => 'weblogic',
    weblogic_password           => 'weblogic1',
    os_user                     => 'oracle',
    os_group                    => 'dba',
    log_dir                     => $log_dir,
    download_dir                => $dwnld_dir,
    log_output                  => true,
  }

  orawls::nodemanager{'nodemanager12c':
    version                     => $version,
    weblogic_home_dir           => $wl_home,
    middleware_home_dir         => $mw_home,
    jdk_home_dir                => $jdk_home,
    nodemanager_port            => 5556,
    nodemanager_secure_listener => true,
    domain_name                 => 'Wls12c',
    os_user                     => $os_user,
    os_group                    => $os_group,
    log_dir                     => $log_dir,
    download_dir                => $dwnld_dir,
    log_output                  => true,
    sleep                       => 20,
    properties                  => {},
  }

  orawls::control{'startWLSAdminServer12c':
    domain_name                 => 'Wls12c',
    server_type                 => 'admin',
    target                      => 'Server',
    server                      => 'AdminServer',
    action                      => 'start',
    weblogic_home_dir           => $wl_home,
    middleware_home_dir         => $mw_home,
    jdk_home_dir                => $jdk_home,
    weblogic_user               => 'weblogic',
    weblogic_password           => 'weblogic1',
    adminserver_address         => $address,
    adminserver_port            => 7001,
    nodemanager_port            => 5556,
    nodemanager_secure_listener => true,
    os_user                     => $os_user,
    os_group                    => $os_group,
    download_dir                => $dwnld_dir,
    log_output                  => true,
  }

  orawls::packdomain{'Wls12c':
    weblogic_home_dir   => $wl_home,
    middleware_home_dir => $mw_home,
    jdk_home_dir        => $jdk_home,
    wls_domains_dir     => "${mw_home}/user_projects/domains/",
    domain_name         => 'Wls12c',
    os_user             => $os_user,
    os_group            => $os_group,
    download_dir        => '/var/tmp/',
  }

  wls_machine { 'server0':
    ensure            => 'present',
    listenaddress     => 'localhost',
    listenport        => '5556',
    machinetype       => 'UnixMachine',
    nmtype            => 'SSL',
  }

  wls_machine { 'server1':
    ensure            => 'present',
    listenaddress     => '192.168.0.174',
    listenport        => '5556',
    machinetype       => 'UnixMachine',
    nmtype            => 'SSL',
  }





}
