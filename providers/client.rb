#
# Cookbook Name:: mysql-wrapper
# Provider:: client
#
# Copyright 2014, Naoya Nakazawa
#
# All rights reserved - Do Not Redistribute
#
# Based on: Chef::Provider::MysqlService
# https://github.com/opscode-cookbooks/mysql/blob/master/libraries/provider_mysql_service_rhel.rb
#

def whyrun_supported?
  true
end

action :create  do
  converge_by('mysql-wrapper client create') do
    ## Support MySQL 5.6 for CentOS 5.x
    case node['platform_version'].to_i.to_s
    when '5'
      case new_resource.version
      when '5.6'
        packages_name = [ 'MySQL-client', 'MySQL-devel' ]
        # MySQL Bugs #67851: http://bugs.mysql.com/bug.php?id=67851
        devel_version = '5.5.38-1.rhel5'
      end
    end

    packages_name.each do |package_name|
      package package_name do
        if package_name =~ /^.*devel$/
          version devel_version ## add version
        else
          version new_resource.mysql_wrapper[:version] ## add version
        end
        action :nothing
      end.run_action(:install)
    end

    ## fix mysql-config pkglibdir
    execute 'mysql-config-fix' do
      command "sed -i -e \"s/pkglibdir='\\/usr\\/lib64'/pkglibdir='\\/usr\\/lib64\\/mysql'/\" /usr/bin/mysql_config"
      only_if "grep \"pkglibdir='/usr/lib64'\" /usr/bin/mysql_config"
      action :nothing
    end.run_action(:run)

    recipe_eval do
      run_context.include_recipe 'build-essential::default'
    end

    chef_gem 'mysql' do
     action :install
    end
  end
end

action :delete do
  converge_by('mysql-wrapper client delete') do
    ## Support MySQL 5.6 for CentOS 5.x
    case node['platform_version'].to_i.to_s
    when '5'
      case new_resource.version
      when '5.6'
        packages_name = [ 'MySQL-client', 'MySQL-devel' ]
      end
    end

    packages_name.each do |package_name|
      package package_name do
        version new_resource.mysql_wrapper[:version] ## add version
        action :remove
      end
    end
  end
end

alias_method :action_add, :action_create
alias_method :action_remove, :action_delete
