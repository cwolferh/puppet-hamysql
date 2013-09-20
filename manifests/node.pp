class hamysql::node (
  $mysql_root_password         = $quickstack::params::mysql_root_password,
  $keystone_db_password        = $quickstack::params::keystone_db_password,
  $glance_db_password          = $quickstack::params::glance_db_password,
  $nova_db_password            = $quickstack::params::nova_db_password,
  $cinder_db_password          = $quickstack::params::cinder_db_password,

) inherits quickstack::params {

    class {'openstack::db::mysql':
        mysql_root_password  => $mysql_root_password,
        keystone_db_password => $keystone_db_password,
        glance_db_password   => $glance_db_password,
        nova_db_password     => $nova_db_password,
        cinder_db_password   => $cinder_db_password,
        neutron_db_password  => '',

        # MySQL
        mysql_bind_address     => '0.0.0.0',
        mysql_account_security => true,

        # Cinder
        cinder                 => false,

        # neutron
        neutron                => false,

        allowed_hosts          => '%',
        enabled                => true,
    }

    yumrepo { 'clusterlabs' :
        baseurl => "http://clusterlabs.org/64z.repo",
        enabled => 1,
        priority => 1,
    }

    class {'pacemaker::corosync':
        cluster_name => "hamysql", 
        cluster_members => "192.168.200.2 192.168.200.3 192.168.200.4 ", }
        require => Class['openstack::db::mysql'], Yumrepo['clusterlabs'],
    }

    class {"pacemaker::resource::ip":
      ip_address => "192.168.200.10",
      group => "my_group",
    }

    class {"pacemaker::resource::filesystem":
       device => "192.168.200.255:/var/www/html",
       directory => "/var/lib/mysql",
       fstype => "nfs",
    }
    class {"pacemaker::resource::lsb":
       name => "mysql",
    }
}
