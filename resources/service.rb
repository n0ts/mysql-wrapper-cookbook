#
# Cookbook Name:: mysql-wrapper
# Resouces:: service
#
# Copyright 2014, Naoya Nakazawa
#
# All rights reserved - Do Not Redistribute
#

actions :create

default_action :create

## default attribute for resource_mysql_service
attribute :service_name, :kind_of => String, :default => node['mysql']['service_name']
attribute :template_source, :kind_of => String, :default => ''
attribute :port, :kind_of => String, :default => node['mysql']['port']
attribute :version, :kind_of => String, :default => node['mysql']['version']
attribute :data_dir, :kind_of => String, :default => node['mysql']['data_dir']
attribute :allow_remote_root, :kind_of => [TrueClass, FalseClass], :default => node['mysql']['allow_remote_root']
attribute :remove_anonymous_users, :kind_of => [TrueClass, FalseClass], :default => node['mysql']['remove_anonymous_users']
attribute :remove_test_database, :kind_of => [TrueClass, FalseClass], :default => node['mysql']['remove_test_database']
attribute :root_network_acl, :kind_of => Array, :default => []
attribute :server_root_password, :kind_of => String, :default => node['mysql']['server_root_password']
attribute :server_debian_password, :kind_of => String, :default => node['mysql']['server_debian_password']
attribute :server_repl_password, :kind_of => String, :default => node['mysql']['server_repl_password']

## additional attribute
attribute :mysql_wrapper, :kind_of => [Array, Hash], :default => nil
