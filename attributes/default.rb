#
# Cookbook Name:: database-bulk
# Attribute:: default
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

default['database-bulk']['host']      = '127.0.0.1'
default['database-bulk']['user']      = 'root'
default['database-bulk']['password']  = nil
default['database-bulk']['data_bag']  = 'users'
default['database-bulk']['sleep']     = 7
default['database-bulk']['bcc_to']    = nil

