#
# Cookbook Name:: mysql-wrapper
# Recipe:: default
#
# Copyright 2014, Naoya Nakazawa
#
# All rights reserved - Do Not Redistribute
#

package node['mysql-wrapper']['package_name']['shared-compat'] do
  name node['mysql-wrapper']['package_name']['shared-compat']
  version node['mysql-wrapper']['version']
  action :install
  not_if {  node['mysql-wrapper']['package_name']['shared-compat'].empty? }
end

directory '/usr/local/etc/mysql' do
  action :create
end

template '/usr/local/etc/mysql/mysql_slave.sql' do
  source 'mysql_slave.sql.erb'
  action :create
  not_if { node['mysql-wrapper']['master_host'].empty? }
end
