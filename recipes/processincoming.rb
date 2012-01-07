#
# Cookbook Name:: reprepro
# Recipe:: processincoming
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


directory "/etc/reprepro-list.d/"

cookbook_file "/usr/local/sbin/reprepro-incoming" do
  source      "reprepro-incoming"
  mode        0755
end

cookbook_file "/root/.bashrc" do
  source      "bashrc"
end

cookbook_file "/root/.gnupg/gpg.conf" do
  source      "gpg.conf"
end


cron "cron-process-incoming" do
  command "/usr/local/sbin/reprepro-incoming"
  mailto node[:reprepro][:cron_mail]
end

