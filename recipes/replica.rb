#
# Cookbook Name:: solr
# Recipe:: replica
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


include_recipe "solr::user"
include_recipe "solr::install"
include_recipe "solr::install_newrelic"

node.set[:solr][:service_name] = 'solr-replica'

# configure solr
execute "copy example solr home into master" do
  command "rsync -a /opt/solr/home_example/ #{node[:solr][:replica][:home]}/ && chown -R #{node[:solr][:solr_user]}:root #{node[:solr][:replica][:home]}/"
  not_if "ls #{node[:solr][:replica][:home]}/"
end

template "#{node[:solr][:replica][:home]}/log.conf" do
  source "solr-replica-log.conf.erb"
  owner node[:solr][:solr_user]
  mode "0700"
  notifies :restart, "service[#{node[:solr][:service_name]}]"
end

template "#{node[:solr][:replica][:home]}/solr/conf/solrconfig.xml" do
  owner node[:solr][:solr_user]
  mode "0600"
  variables({
    :role => "replica",
    :config => node[:solr]
  })
end

# create/import smf manifest
include_recipe 'solr::solr_service'