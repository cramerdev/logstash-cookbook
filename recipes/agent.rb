#
# Cookbook Name:: logstash
# Recipe:: agent
#
# Copyright 2011, Joshua Timberman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'logstash::default'
component = 'agent'

root_group = value_for_platform(
  ['openbsd', 'freebsd', 'mac_os_x'] => { 'default' => 'wheel' },
  'default' => 'root'
)

case node[:platform]
when "redhat","centos","scientific","fedora","suse","arch"
  apache_log_dir = '/var/log/httpd'
when "debian","ubuntu"
  apache_log_dir = '/var/log/apache2'
else
  apache_log_dir = '/var/log/apache2'
end

template "#{node['logstash']['config_path']}/agent.conf" do
  source "agent.conf.erb"
  owner "root"
  group root_group
  mode 0644
  notifies :restart, "service[logstash-agent]"
  variables(
    :apache_log_dir => apache_log_dir
    )
end

case node['logstash']['init_style']
when 'daemonize'

  case node[:platform]
  when 'redhat', 'centos', 'scientific'
    include_recipe "yum::epel"

    package "daemonize" do
      action :upgrade
    end

    template "/etc/init.d/logstash-#{component}" do
      source "logstash-#{component}.init.erb"
      owner "root"
      group root_group
      mode 0755
      notifies :restart, "service[logstash-#{component}]"
    end

    service "logstash-#{component}" do
      supports :status => true, :start => true, :stop => true, :restart => true
      action [:enable, :start]
    end
  end

when 'runit'
  runit_service "logstash-#{component}"
else
  service "logstash-#{component}" do
    action :nothing
    subscribes :restart, 'remote_file[logstash.jar]'
  end
end
