class profile_wls (
  $java_home_dir       = '/usr/java/jdk1.8.0_45',
  $version             = '12.2.1',
  $middleware_home_dir = '/opt/oracle/middleware',
  $weblogic_home_dir   = '/opt/oracle/middleware/wlserver',
  $source_file         = '/var/tmp/fmw_12.2.1.0.0_wls.jar',
  $dbname              = '',
  $dbserver            = '',
)
{
  include ::fmw_jdk::rng_service

  class { '::fmw_jdk::install':
    java_home_dir => $java_home_dir,
    source_file   => '/var/tmp/jdk-8u45-linux-x64.rpm',
  }

  class { '::fmw_wls':
      version             => $version,
      middleware_home_dir => $middleware_home_dir,
  }

  Class['fmw_wls::setup'] ->
    Class['fmw_wls::install']

  include ::fmw_wls::setup

  class { '::fmw_wls::install':
    java_home_dir => $java_home_dir,
    source_file   => $source_file,
    install_type  => 'wls', # 'wls' is the default
  }

  class { '::fmw_domain':
    version                    => $version,
    java_home_dir              => $java_home_dir,
    middleware_home_dir        => $middleware_home_dir,
    weblogic_home_dir          => $weblogic_home_dir,
    domains_dir                => "${middleware_home_dir}/user_projects/domains",
    apps_dir                   => "${middleware_home_dir}/user_projects/applications",
    domain_name                => 'base_domain',
    weblogic_password          => 'Welcome01',
    adminserver_listen_address => $::ipaddress,
    nodemanager_listen_address => $::ipaddress,
  }

  include ::fmw_domain::domain
  include ::fmw_domain::nodemanager
  include ::fmw_domain::adminserver

}




