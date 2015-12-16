name             'database-bulk'
maintainer       'Boye Holden'
maintainer_email 'boye.holden@hist.no'
license          'Apache 2.0'
description      'Installs/Configures database-bulk'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'

%w(mysql2_chef_gem).each do |pkg|
  depends pkg
end

supports 'debian', '>= 6.0'
supports 'ubuntu', '>= 12.04'