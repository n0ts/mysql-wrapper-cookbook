#
# Cookbook Name:: mysql-wrapper
# Attribute:: default
#
# Copyright 2014, Naoya Nakazawa
#
# All rights reserved - Do Not Redistribute
#

include_attribute 'mysql::default'

default['mysql-wrapper'] = {
  'package_name' => {
    'shared-compat' => 'MySQL-shared-compat',
    'server' => 'MySQL-server',
    'client' => 'MySQL-client',
    'devel' => 'MySQL-devel',
  },
  'version' => '5.6.19-1.rhel6',
  'max_connections' => 32,
  'thead_cache_size' => 0,
  'expire_logs_days' => 30,
  'innodb_buffer_pool_size' => '128M',
  'innodb_buffer_pool_instances' => 2,
  'innodb_data_file_path' => 'ibdata1:10M:autoextend',
  'master_host' => '',
}
