#
# OVH SAS
#
# Class to create a SSL certificate and a key
#
# @author Arnaud Morin <arnaud.morin@corp.ovh.com>
# @source https://github.com/TracyWebTech/puppet-openssl
# @fork https://github.com/arnaudmorin/puppet-openssl
#
define openssl::certificate(
  $country,
  $state,
  $city,
  $common_name,
  $organization,
  $organization_unit  = '',
  $base_dir           = '/usr/local/share/ca-certificates/',
  $key_dir            = '/etc/ssl/private',
  $openssl_bin        = '/usr/bin/openssl',
  $type               = 'rsa',
  $bits               = 4096,
  $days               = 3650,
  $owner              = 'root',
  $group              = 'root',
) {
  include 'update'

  # Build some vars
  $ssl_cert = "${base_dir}/${name}.crt"
  $ssl_key = "${key_dir}/${name}.key"
  $ssl_cmd = "${base_dir}/${name}.sh"

  # Build the subject
  $subject = join(['',
    "C=${country}",
    "ST=${state}",
    "L=${city}",
    "O=${organization}",
    "OU=${organization_unit}",
    "CN=${common_name}",
  ], '/')

  # The command to be executed
  $cmd = join([
    $openssl_bin,
    'req',
    '-new',
    "-newkey ${type}:${bits}",
    "-days ${days}",
    '-nodes',
    '-x509',
    "-subj '${subject}'",
    "-keyout ${ssl_key}",
    "-out ${ssl_cert}",
  ], ' ')

  # Keep the command in a file to trigger the refresh when command change
  file { $ssl_cmd:
    ensure  => file,
    notify  => Exec[$cmd],
    content => $cmd,
  }

  # Execute the command
  exec { $cmd:
    refreshonly => true,
    notify      => Exec['/usr/sbin/update-ca-certificates'],
  }

  # Make sure files belong to the correct user
  file { [$ssl_cert, $ssl_key]:
    mode    => '0600',
    owner   => $owner,
    group   => $group,
    require => Exec[$cmd],
  }
}
