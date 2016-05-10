class profile_wls::server (
  $adminserver_address,
  $adminserver_port,
  $jdk_home            = '/usr/java/jdk1.8.0_45',
  $version             = 1221,
  $filename            = 'fmw_12.2.1.0.0_wls.jar',
  $orabase             = '/opt/oracle',
  $mw_home             = '/opt/oracle/middleware12c',
  $wl_home             = '/opt/oracle/middleware12c/wlserver',
  $os_user             = 'oracle',
  $os_group            = 'dba',
  $dwnld_dir           = '/var/tmp/',
  $src_dir             = '/var/tmp/',
  $log_dir             = '/var/tmp/',
  $address             = $::ipaddress,
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

  orawls::copydomain{'Wls12c':
    version             => $version,
    weblogic_home_dir   => $wl_home,
    middleware_home_dir => $mw_home,
    jdk_home_dir        => $jdk_home,
    wls_domains_dir     => "${mw_home}/user_projects/domains",
    wls_apps_dir        => "${mw_home}/user_projects/applications",
    domain_name         => 'Wls12c',
    os_user             => $os_user,
    os_group            => $os_group,
    download_dir        => '/var/tmp/',
    log_dir             => $log_dir,
    log_output          => true,
    use_ssh             => false,
    domain_pack_dir     => '/var/tmp/',
    adminserver_address => $adminserver_address,
    adminserver_port    => $adminserver_port,
    weblogic_user       => 'weblogic',
    weblogic_password   => 'weblogic1',
    server_start_mode   => 'dev',
  }
}
