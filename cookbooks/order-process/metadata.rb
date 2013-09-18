name             'order-process'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures order-process'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'


depends "java"

depends "daemonlib"
depends "commons-daemon"
depends "embedded-webapp"
depends "id-generator"

depends "mca-structure"
depends "mbv-search"
