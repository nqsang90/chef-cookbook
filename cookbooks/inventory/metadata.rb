name             'inventory'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures inventory'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "java"
depends "account"
depends "installment"

depends "daemonlib"
depends "commons-daemon"
depends "embedded-webapp"
depends "id-generator"

depends "deamon-service"
