#
# Cookbook Name:: reprepro
# Recipe:: default
#
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Arthur Gautier <aga@zenexity.com>
# Copyright 2010, Opscode
# Copyright 2011, Zenexity, Inc.
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

include_recipe "nginx"

apt_repos = data_bag("reprepro")

%w{apt-utils reprepro}.each do |pkg|
  package pkg
end

apt_repos.each do |apt_repo_name|
  apt_repo = data_bag_item("reprepro", apt_repo_name)
  Chef::Log.debug("loading reprepro #{apt_repo_name}")

  reprepro_repo apt_repo_name do
    repo apt_repo
  end
end

nginx_site "000-default" do
  action :disable
end
