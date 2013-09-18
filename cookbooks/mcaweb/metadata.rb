name             'mcaweb'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures mcaweb'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.0'


depends "mbv-tomcat"
depends "mbv-search"
depends "xacct"
depends "installment"
depends "inventory"
depends "mca"
depends "mfs"
depends "account"
depends "order-process"
