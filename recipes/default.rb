#
# Cookbook Name:: database-bulk
# Recipe:: default
#
# Copyright 2015, HiST IIE
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

# Manage MySQL gem
mysql2_chef_gem 'default' do
  action :install
end

# MySQL connection
mysql_connection = {
    :host => node['database-bulk']['host'],
    :username => node['database-bulk']['user'],
    :password => node['database-bulk']['password'] || node['mysql']['server_root_password']
}

# Empty holder for users and groups
users = {}
groups = {}

# Find users to create
node['database-bulk']['grouping'].each do |group, data|
  if data['is_group']
    groups["#{node['database-bulk']['group_prefix']}#{group}"] = {
        'action' => data['action'],
        'members' => data['users']
    }
  else
    data['users'].each do |user|
      users[user] = {
          'action' => data['action']
      }
    end
  end
end

# Find current status for users, and cleanup
node.set['database-bulk']['users'] = {} unless node['database-bulk']['users']
node['database-bulk']['users'].each do |user, data|
  if users.has_key?(user)
    users[user].merge!({
                           'time' => data['time'],
                           'status' => data['status'],
                           'password' => data['password'],
                           'email' => data['email']
                       })
  else
    node.set['database-bulk']['users'].delete(user)
  end
end

# Find current status for users, and cleanup
node.set['database-bulk']['groups'] = {} unless node['database-bulk']['groups']
node['database-bulk']['groups'].each do |user, data|
  if groups.has_key?(user)
    groups[user].merge!({
                           'time' => data['time'],
                           'status' => data['status'],
                           'password' => data['password'],
                           'members' => data['members']
                       })
  else
    node.set['database-bulk']['groups'].delete(user)
  end
end

# Handle users and databases
users.each do |user, data|
  dup = data.dup
  dup['password'] = data['password'] || ([nil]*8).map { ((48..57).to_a+(65..90).to_a+(97..122).to_a).sample.chr }.join

  mysql_database user do
    connection    mysql_connection
    action        data['action'].to_sym
  end

  mysql_database_user user do
    connection    mysql_connection
    password      dup['password']
    host          '%'
    action        data['action'].to_sym
  end

  if data['action'] == 'create'
    mysql_database_user user do
      connection    mysql_connection
      password      dup['password']
      host          '%'
      database_name user
      privileges    [:all]
      action        :grant
    end
  end

  unless dup['email']
    search(node['database-bulk']['data_bag'], "id:#{user} AND NOT email:NA") do |bag_data|
      dup['email'] = bag_data['email']
    end unless Chef::Config[:solo]
    dup['email'] = "#{user}@#{node['database-bulk']['domain']}" unless dup['email']
  end

  if dup['action'] == 'create' and !dup['status']
    template "db-mail-#{user}" do
      source 'email.erb'
      path "#{Chef::Config['file_cache_path']}/bulk-mail-#{user}"
      variables :user => user, :password => dup['password']
      notifies :run, "execute[db-send-#{user}]", :immediately
    end

    execute "db-send-#{user}" do
      cmd  = "mail -s 'MySQL database og konto opprettet for #{user} ved IIE'"
      cmd += " -aFrom:#{node['database-bulk']['from']}" if node['database-bulk']['from']
      cmd += " -b #{node['database-bulk']['bcc_to'].join(',')}" if node['database-bulk']['bcc_to']
      cmd += " #{dup['email']}"
      cmd += " < #{Chef::Config['file_cache_path']}/bulk-mail-#{user}"
      command cmd
      notifies :run, "execute[db-delete-#{user}]", :immediately
      action :nothing
    end

    execute "db-delete-#{user}" do
      command "rm #{Chef::Config['file_cache_path']}/bulk-mail-#{user} && sleep #{node['database-bulk']['sleep']}"
      action :nothing
    end
  end

  dup['time'] = Time.now if dup['status'] != dup['action']
  dup['status'] = dup['action']
  node.set['database-bulk']['users'][user] = dup
end

# Handle users and databases
groups.each do |user, data|
  dup = data.dup
  dup['password'] = data['password'] || ([nil]*8).map { ((48..57).to_a+(65..90).to_a+(97..122).to_a).sample.chr }.join

  mysql_database user do
    connection    mysql_connection
    action        data['action'].to_sym
  end

  mysql_database_user user do
    connection    mysql_connection
    password      dup['password']
    host          '%'
    action        data['action'].to_sym
  end

  if data['action'] == 'create'
    mysql_database_user user do
      connection    mysql_connection
      password      dup['password']
      host          '%'
      database_name user
      privileges    [:all]
      action        :grant
    end
  end

  if dup['action'] == 'create' and !dup['status']
    dup['members'].each do |name|
      email = false
      search(node['database-bulk']['data_bag'], "id:#{name} AND NOT email:NA") do |bag_data|
        email = bag_data['email']
      end unless Chef::Config[:solo]
      email = "#{name}@#{node['database-bulk']['domain']}" unless email

      template "db-mail-group-#{user}-#{name}" do
        source 'email.erb'
        path "#{Chef::Config['file_cache_path']}/bulk-mail-#{name}"
        variables :user => user, :password => dup['password']
        notifies :run, "execute[db-send-group-#{user}-#{name}]", :immediately
      end

      execute "db-send-group-#{user}-#{name}" do
        cmd  = "mail -s 'MySQL database og konto opprettet for #{user} ved IIE'"
        cmd += " -aFrom:#{node['database-bulk']['from']}" if node['database-bulk']['from']
        cmd += " -b #{node['database-bulk']['bcc_to'].join(',')}" if node['database-bulk']['bcc_to']
        cmd += " #{email}"
        cmd += " < #{Chef::Config['file_cache_path']}/bulk-mail-#{name}"
        command cmd
        notifies :run, "execute[db-delete-group-#{user}-#{name}]", :immediately
        action :nothing
      end

      execute "db-delete-group-#{user}-#{name}" do
        command "rm #{Chef::Config['file_cache_path']}/bulk-mail-#{name} && sleep #{node['database-bulk']['sleep']}"
        action :nothing
      end
    end
  end

  dup['time'] = Time.now if dup['status'] != dup['action']
  dup['status'] = dup['action']
  node.set['database-bulk']['groups'][user] = dup
end