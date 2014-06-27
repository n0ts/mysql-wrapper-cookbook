#
# Cookbook Name:: mysql-wrapper
# Provider:: service
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
  converge_by('mysql-wrapper service create') do
    ## Support MySQL 5.6 for CentOS 5.x
    case node['platform_version'].to_i.to_s
    when '5'
      case new_resource.version
      when '5.6'
        base_dir = ''
        include_dir = "#{base_dir}/etc/mysql/conf.d"
        log_dir = '/var/log/mysql'
        prefix_dir = '/usr'
        lc_messages_dir = nil
        run_dir = '/var/run/mysqld'
        pid_file = "#{run_dir}/mysql.pid"
        socket_file = '/var/lib/mysql/mysql.sock'
        package_name = 'MySQL-server'
        service_name = 'mysql'
      end
    end

    ## add group & user
    group 'mysql' do
      action :create
    end

    user 'mysql' do
      home node['mysql']['data_dir']
      gid 'mysql'
      comment 'MySQL server'
      action :create
    end

    ## add log_dir
    directory log_dir do
      owner 'mysql'
      group 'mysql'
      mode '0750'
      action :create
    end

    directory include_dir do
      owner 'mysql'
      group 'mysql'
      mode '0750'
      recursive true
      action :create
    end

    directory run_dir do
      owner 'mysql'
      group 'mysql'
      mode '0755'
      recursive true
      action :create
    end

    directory new_resource.data_dir do
      owner 'mysql'
      group 'mysql'
      mode '0755'
      recursive true
      action :create
    end

    ##
    # NOTE
    # - service[service_name] => template["#{base_dir}/etc/my.cnf"] to
    #   template["#{base_dir}/etc/my.cnf"] => service[service_name]
    #
    template "#{include_dir}/local.cnf" do
      source 'local.cnf'
      owner 'mysql'
      group 'mysql'
      action :create
    end

    template "#{base_dir}/etc/my.cnf" do
      if new_resource.template_source.nil?
        source "#{new_resource.version}/my.cnf.erb"
        cookbook 'mysql'
      else
        source new_resource.template_source
      end
      owner 'mysql'
      group 'mysql'
      mode '0600'
      variables(
                :base_dir => base_dir,
                :data_dir => new_resource.data_dir,
                :include_dir => include_dir,
                :lc_messages_dir => lc_messages_dir,
                :pid_file => pid_file,
                :port => new_resource.port,
                :socket_file => socket_file,
                ## additional parameters
                :log_dir => log_dir,
                :mysql_wrapper => new_resource.mysql_wrapper,
                )
      action :create_if_missing ## do not replace
      ##notifies :run, 'bash[move mysql data to datadir]' ## do not run
      ##notifies :restart, "service[#{service_name}]" ## do not restart
    end

    ##bash 'move mysql data to datadir' do
    ##  user 'root'
    ##  code <<-EOH
    ##          service #{service_name} stop \
    ##          && for i in `ls #{base_dir}/var/lib/mysql | grep -v mysql.sock` ; do mv #{base_dir}/var/lib/mysql/$i #{new_resource.data_dir} ; done
    ##          EOH
    ##  action :nothing
    ##  creates "#{new_resource.data_dir}/ibdata1"
    ##  creates "#{new_resource.data_dir}/ib_logfile0"
    ##  creates "#{new_resource.data_dir}/ib_logfile1"
    ##end

    ##
    bash 'reset mysql data' do
      user 'root'
      code <<-EOH
rm -f /usr/my.cnf
rm -fr #{new_resource.data_dir}/*
mysql_install_db --user=mysql --datadir=#{new_resource.data_dir}
EOH
      action :nothing
    end

    package package_name do
      version new_resource.mysql_wrapper[:version] ## add version
      action :install
      notifies :run, 'bash[reset mysql data]', :immediately ## run bash[reset mysql data]
    end

    execute 'assign-root-password' do
      cmd = "#{prefix_dir}/bin/mysqladmin"
      cmd << ' -u root password '
      cmd << Shellwords.escape(new_resource.server_root_password)
      command cmd
      ##action :run
      ##only_if "#{prefix_dir}/bin/mysql -u root -e 'show databases;'"
      action :nothing
    end

    service service_name do
      supports :restart => true
      action [:start, :enable]
      notifies :run, 'execute[assign-root-password]' ## run execute[assign-root-password]
    end

    execute 'wait for mysql' do
      command "until [ -S #{socket_file} ] ; do sleep 1 ; done"
      action :run
    end

    template '/etc/mysql_grants.sql' do
      cookbook 'mysql-wrapper' ## use mysql-wrapper mysql_grants.sql
      source 'grants/grants.sql.erb'
      owner 'root'
      group 'root'
      mode '0600'
      variables(:config => new_resource)
      action :create
      notifies :run, 'execute[install-grants]'
      ##notifies :run, 'bash[install-grants]'
    end

    if new_resource.server_root_password.empty?
      pass_string = ''
    else
      pass_string = '-p' + Shellwords.escape(new_resource.server_root_password)
    end

    execute 'install-grants' do
      cmd = "#{prefix_dir}/bin/mysql"
      cmd << ' -u root '
      cmd << "#{pass_string} < /etc/mysql_grants.sql"
      command cmd
      action :nothing
    end

    template '/etc/logrotate.d/mysql' do
      source 'mysql_logrotate.erb'
      variables(:log_dir => log_dir)
      action :create
    end
  end
end


alias_method :action_add, :action_create
