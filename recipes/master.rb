#
# Cookbook Name:: solr
# Recipe:: master
#
# Copyright 2013, Wanelo, Inc.
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

node.set[:solr][:service_name] = 'solr-master'

include_recipe "solr4::user"
include_recipe "solr4::install"
#include_recipe "solr4::install_newrelic"

auto_commit_enabled = node[:solr][:config][:auto_commit][:max_docs] && node[:solr][:config][:auto_commit][:max_time]

# configure solr
execute "copy example solr home into master" do
  command "rsync -a /opt/solr/home_example/ #{node[:solr][:master][:home]}/ && chown -R solr:root #{node[:solr][:master][:home]}/"
  not_if "svcs #{node[:solr][:service_name]}"
end

template "#{node[:solr][:master][:home]}/log.conf" do
  source "solr-master-log.conf.erb"
  owner node[:solr][:solr_user]
  mode "0700"
  notifies :restart, "service[#{node[:solr][:service_name]}]"
end

template "#{node[:solr][:master][:home]}/solr/collection1/conf/solrconfig.xml" do
  owner node[:solr][:solr_user]
  mode "0600"
  variables({
    :role => "master",
    :config => node[:solr][:config],
    :master => node[:solr][:master],
    :auto_commit => auto_commit_enabled
  })
  only_if { node[:solr][:uses_default_config] || !::File.exists?("#{node[:solr][:replica][:home]}/solr/collection1/conf/solrconfig.xml") }
end

# create/import smf manifest
include_recipe 'solr4::solr_service'
