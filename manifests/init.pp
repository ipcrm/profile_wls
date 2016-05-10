class profile_wls (
  $jdk_home  = '/usr/java/jdk1.8.0_45',
  $version   = 1221,
  $filename  = 'fmw_12.2.1.0.0_wls.jar',
  $orabase   = '/opt/oracle',
  $mw_home   = '/opt/oracle/middleware12c',
  $wl_home   = '/opt/oracle/middleware12c/wlserver',
  $os_user   = 'oracle',
  $os_group  = 'dba',
  $dwnld_dir = '/var/tmp/',
  $src_dir   = '/var/tmp/',
  $log_dir   = '/var/tmp/',
){
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

  orawls::domain { 'wlsDomain12c':
    version                     => $version,
    weblogic_home_dir           => $wl_home,
    middleware_home_dir         => $mw_home,
    jdk_home_dir                => $jdk_home,
    domain_template             => 'standard',
    domain_name                 => 'Wls12c',
    development_mode            => false,
    adminserver_name            => 'AdminServer',
    adminserver_address         => 'localhost',
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
    jdk_home_dir                => $jdk_home,
    weblogic_user               => 'weblogic',
    weblogic_password           => 'weblogic1',
    adminserver_address         => 'localhost',
    adminserver_port            => 7001,
    nodemanager_port            => 5556,
    nodemanager_secure_listener => true,
    os_user                     => $os_user,
    os_group                    => $os_group,
    download_dir                => $dwnld_dir,
    log_output                  => true,
  }







}
