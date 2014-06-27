#
# Cookbook Name:: mysql-wrapper
# Recipe:: client
#
# Copyright 2014, Naoya Nakazawa
#
# All rights reserved - Do Not Redistribute
#

mysql_wrapper_client 'default' do
  version node['mysql']['version']
  mysql_wrapper node['mysql-wrapper']
  action :create
end
