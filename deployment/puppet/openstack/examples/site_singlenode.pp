#
# Example of how to deploy basic single openstack environment.
#

# deploy a script that can be used to test nova
class { 'openstack::test_file': }

####### shared variables ##################


# this section is used to specify global variables that will
# be used in the deployment of multi and single node openstack
# environments

# assumes that eth0 is the public interface
$public_interface        = 'eth0'
# assumes that eth1 is the interface that will be used for the vm network
# this configuration assumes this interface is active but does not have an
# ip address allocated to it.
$private_interface       = 'eth1'
# credentials
$admin_email             = 'root@localhost'
$admin_password          = 'nova'
$keystone_db_password    = 'keystone_db_pass'
$keystone_admin_token    = 'keystone_admin_token'
$nova_db_password        = 'nova_pass'
$nova_user_password      = 'nova_pass'
$glance_db_password      = 'glance_pass'
$glance_user_password    = 'glance_pass'
$horizon_secret_key      = 'dummy_secret_key'
$mysql_root_password     = 'sql_pass'
$rabbit_password         = 'openstack_rabbit_password'
$rabbit_user             = 'openstack_rabbit_user'
$fixed_range             = '10.0.58.0/24'
$floating_range          = '10.0.75.128/27'
$vlan_start              = 300
# switch this to true to have all service log at verbose
$verbose                 = true
# by default it does not enable atomatically adding floating IPs
$auto_assign_floating_ip = false

# Cinder service
$cinder                  = false
$quantum                 = false
$swift                   = false
$use_syslog              = false


# Packages repo setup
$mirror_type = 'internal'
stage { 'openstack-custom-repo': before => Stage['main'] }
class { 'openstack::mirantis_repos': stage => 'openstack-custom-repo', type => $mirror_type }

# OpenStack packages and customized component versions to be installed.
# Use 'latest' to get the most recent ones or specify exact version if you need to install custom version.
case $::osfamily {
  "Debian":  {
     $rabbitmq_version_string = '2.7.1-0ubuntu4'
  }
  "RedHat": {
     $rabbitmq_version_string = '2.8.7-2.el6'
  }
}

$openstack_version = {
  'keystone'         => 'latest',
  'glance'           => 'latest',
  'horizon'          => 'latest',
  'nova'             => 'latest',
  'novncproxy'       => 'latest',
  'cinder'           => 'latest',
  'rabbitmq_version' => $rabbitmq_version_string,
}

# Every node should be deployed as all-in-one openstack installations.
node default {

  # include 'apache'

  class { 'openstack::all':
    public_address          => $ipaddress_eth0,
    public_interface        => $public_interface,
    private_interface       => $private_interface,
    admin_email             => $admin_email,
    admin_password          => $admin_password,
    keystone_db_password    => $keystone_db_password,
    keystone_admin_token    => $keystone_admin_token,
    nova_db_password        => $nova_db_password,
    nova_user_password      => $nova_user_password,
    glance_db_password      => $glance_db_password,
    glance_user_password    => $glance_user_password,
    secret_key              => $horizon_secret_key,
    mysql_root_password     => $mysql_root_password,
    rabbit_password         => $rabbit_password,
    rabbit_user             => $rabbit_user,
    libvirt_type            => 'qemu',
    floating_range          => $floating_range,
    fixed_range             => $fixed_range,
    verbose                 => $verbose,
    auto_assign_floating_ip => $auto_assign_floating_ip,
    network_config          => { 'vlan_start' => $vlan_start },
    purge_nova_config       => false,
    cinder                  => $cinder,
    quantum                 => $quantum,
    swift                   => $swift,
  }

  class { 'openstack::auth_file':
    admin_password       => $admin_password,
    keystone_admin_token => $keystone_admin_token,
    controller_node      => '127.0.0.1',
  }

}

