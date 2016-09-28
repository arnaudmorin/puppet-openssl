#
# OVH SAS
#
# Class to create a SSL certificate and a key
#
# @author Arnaud Morin <arnaud.morin@corp.ovh.com>
# @source https://github.com/TracyWebTech/puppet-openssl
# @fork https://github.com/arnaudmorin/puppet-openssl
#
class openssl::update() {
  # Update ca-certificates
  exec { '/usr/sbin/update-ca-certificates':
    refreshonly => true,
  }
}
