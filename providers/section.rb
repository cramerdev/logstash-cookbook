# Cookbook Name:: logstash
# Provider:: section
#
# Copyright 2012, Cramer Development, Inc.
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

action :create do
  template "#{node['logstash']['config_path']}/#{new_resource.name}.conf" do
    cookbook 'logstash'
    source 'section.conf.erb'
    owner node['logstash']['user_login']
    group node['logstash']['user_group']
    mode '0600'
    variables({
      :name   => new_resource.name,
      :type   => new_resource.type,
      :plugin => new_resource.plugin,
      :fields => new_resource.fields
    })
    notifies :restart, 'service[logstash-agent]'
  end
end

action :delete do
  file "#{node['logstash']['config_path']}/#{new_resource.name}.conf" do
    action :delete
  end
end
