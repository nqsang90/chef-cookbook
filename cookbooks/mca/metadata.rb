name             'mca'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures mca'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.0'

depends "java"

depends "daemonlib"
depends "commons-daemon"
depends "embedded-webapp"
depends "id-generator"

depends "mca-structure"

