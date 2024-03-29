#
# Cookbook Name:: mysql-wrapper
# Recipe:: server
#
# Copyright 2014, Naoya Nakazawa
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'mysql-wrapper'

mysql_wrapper_service node['mysql']['service_name'] do
  port node['mysql']['port']
  data_dir node['mysql']['data_dir']
  server_root_password node['mysql']['server_root_password']
  server_debian_password node['mysql']['server_debian_password']
  server_repl_password node['mysql']['server_repl_password']
  allow_remote_root node['mysql']['allow_remote_root']
  remove_anonymous_users node['mysql']['remove_anonymous_users']
  remove_test_database node['mysql']['remove_test_database']
  root_network_acl node['mysql']['root_network_acl']
  version node['mysql']['version']
  mysql_wrapper node['mysql-wrapper']
  template_source 'my.cnf.erb'
  action :create
end
