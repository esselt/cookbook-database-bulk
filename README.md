Description
===========

Cookbook that sets up a traditional LAMP stack.

Requirements
------------

Chef version 12.0+

#### cookbooks
- `lamp-stack` - Installs and configures full LAMP-stack
- `mysql2_chef_gem` - Manages databases and users

## Platform

Supported platforms by platform family:

* debian (debian, ubuntu)

Attributes
----------

* `node['database-bulk']['host']` - Host of MySQL server
* `node['database-bulk']['user']` - Administrator user
* `node['database-bulk']['password']` - Password for administrator user
* `node['database-bulk']['data_bag']` - Data bag to search for emails to users
* `node['database-bulk']['sleep']` - Default time to sleep between emails (7 default)

Usage
-----

#### database-bulk::default

The default recipe creates users defined from attributes.
Passwords and status of user/database is stored in node attributes.

Example role

      'database-bulk' => {
        'host' => '127.0.0.1',      # OPTIONAL. Hostname for database server
        'user' => 'root',           # OPTIONAL. Administrator username on database server
        'password' => nil,          # OPTIONAL. Password of admin user
        'data_bag' => 'users',      # OPTIONAL. Data bag to search for e-mail to users
        'domain' => 'sub.doma.in',  # Domain to which information e-mail is sent
        'from' => 'e@ma.il',        # OPTIONAL. From address of email
        'bcc_to' => ['e@ma.il'],    # OPTIONAL. Send copy of user creation mail to BCC
        'grouping' => {
          'name' => {               # Logic grouping of users or name of group
            'action' => 'create',   # What to do with users, create or drop
            'is_group' => false,    # Can be group (true) then all members gets an e-mail and group name is username
            'users' => {
              'username1',          # Creates database and user with rights to named database
              'username2',
              'username3'
            }
          }
        }
      }

License and Authors
===================
Author:: Boye Holden (<boye.holden@hist.no>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
