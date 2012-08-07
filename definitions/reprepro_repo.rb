#
# Cookbook Name:: reprepro
# Definition:: reprepro_repo
#
# Author:: Arthur Gautier <aga@zenexity.com>
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


define :reprepro_repo, :action => :enable do
  include_recipe "reprepro::processincoming"
  include_recipe "nginx"


  apt_repo_name = params[:name]
  apt_repo = params[:repo]
  uploaders = apt_repo["uploaders"] || {}

  node.set_unless.reprepro[apt_repo_name] = Mash.new
  node.set_unless.reprepro[apt_repo_name].fqdn = apt_repo['fqdn']
  node.set_unless.reprepro[apt_repo_name].description = apt_repo['description']
  node.set_unless.reprepro[apt_repo_name].pgp_email = apt_repo['pgp']['email']

  ruby_block "save node data" do
    block do
      node.save
    end
    action :create
  end

  user "reprepro-#{apt_repo["id"]}" do
    action :create
    comment "User uploading for repo #{apt_repo["id"]}"
    home apt_repo["incoming"]
    shell "/bin/sh"
    system true
  end

  directory "#{apt_repo["repo_dir"]}" do
    owner "nobody"
    group "nogroup"
    mode "0755"
    recursive true
  end

  directory "#{apt_repo["incoming"]}" do
    owner "reprepro-#{apt_repo["id"]}"
    group "nogroup"
    mode "0755"
    recursive true
  end

  directory "#{apt_repo["incoming"]}/.ssh/" do
    owner "reprepro-#{apt_repo["id"]}"
    group "nogroup"
    mode "0755"
  end

  keys = apt_repo["ssh-keys"].map{|user|
    key = data_bag_item('users', user)
    key["keys"]
    }.flatten
  template "#{apt_repo["incoming"]}/.ssh/authorized_keys" do
    owner "reprepro-#{apt_repo["id"]}"
    group "nogroup"
    source "authorized_keys.erb"
    variables(
      :keys => keys)
  end

  directory "#{apt_repo["incoming"]}/tmp" do
    owner "reprepro-#{apt_repo["id"]}"
    group "nogroup"
    mode "0755"
    recursive true
  end

  apt_repo["codenames"].each do |dist|
    directory "#{apt_repo["incoming"]}/#{dist["codename"]}" do
      owner "reprepro-#{apt_repo["id"]}"
      group "nogroup"
      mode "0755"
      recursive true
    end
  end
  
  %w{ conf db dists pool tarballs }.each do |dir|
    directory "#{apt_repo["repo_dir"]}/#{dir}" do
      owner "nobody"
      group "nogroup"
      mode "0755"
    end
  end
  
  %w{ distributions incoming pulls }.each do |conf|
    template "#{apt_repo["repo_dir"]}/conf/#{conf}" do
      source "#{conf}.erb"
      mode "0644"
      owner "nobody"
      group "nogroup"
      variables(
        :codenames => apt_repo["codenames"],
        :architectures => apt_repo["architectures"],
        :incoming => apt_repo["incoming"],
        :pulls => apt_repo["pulls"],
        :uploaders => uploaders
      )
    end
  end

  uploaders.each_pair do |key, value|
    template "#{apt_repo["repo_dir"]}/conf/uploaders-#{key}" do
      source "uploaders.erb"
      owner "nobody"
      group "nogroup"
      variables(
        :distribution => key,
        :uploaders => value
      )
    end
  end

  template "#{apt_repo["repo_dir"]}/README.txt" do
    source "README.erb"
    mode "0644"
    owner "nobody"
    group "nogroup"
    variables(
      :codenames => apt_repo["codenames"],
      :architectures => apt_repo["architectures"],
      :incoming => apt_repo["incoming"],
      :pulls => apt_repo["pulls"],
      :fqdn => apt_repo['fqdn'],
      :desc => apt_repo['description'],
      :pgp_email => "#{apt_repo["pgp"]["email"]}.gpg.key",
      :id => apt_repo['id']
    )
  end
  
  template "#{apt_repo["repo_dir"]}/#{apt_repo["pgp"]["email"]}.gpg.key" do
    source "pgp_key.erb"
    mode "0644"
    owner "nobody"
    group "nogroup"
    variables(
      :pgp_public => apt_repo["pgp"]["public"]
    )
  end
  
  # Load access
  if apt_repo["access"]
    access = search(:ipblocks, apt_repo["access"].map{|item| 
      "id:" << item
      }.join(" OR ")).map{|item|
        item[:blocks]
      }.flatten
  else
    access = nil
  end

  template "#{node[:nginx][:dir]}/sites-available/apt-repo-#{apt_repo_name}.conf" do
    source "apt_repo.conf.erb"
    mode 0644
    owner "root"
    group "root"
    variables(
      :repo_dir => apt_repo["repo_dir"],
      :fqdn => apt_repo["fqdn"],
      :apt_repo_name => apt_repo_name,
      :access => access
    )
    notifies :reload, "service[nginx]", :delayed
  end
  
  nginx_site "apt-repo-#{apt_repo_name}.conf"

  file "/etc/reprepro-list.d/#{apt_repo_name}" do
    content apt_repo["repo_dir"] << "\n"
  end

end
