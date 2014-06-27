#
# Cookbook Name:: mysql-wrapper
# Resouces:: client
#
# Copyright 2014, Naoya Nakazawa
#
# All rights reserved - Do Not Redistribute
#

actions :create, :delete, :add, :remove

default_action :create

## default attribute for resource_mysql_client
attribute :packages_name, :kind_of => Array, :default => ['mysql', 'mysql-devel']
attribute :version, :kind_of => String, :default => node['mysql']['version']

## additional attribute
attribute :mysql_wrapper, :kind_of => [Array, Hash], :default => nil
