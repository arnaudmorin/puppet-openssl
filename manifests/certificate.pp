
define openssl::certificate(
  $country,
  $state,
  $city,
  $common_name,
  $organization,
  $organization_unit = '',
  $openssl_bin = '/usr/bin/openssl',
  $type = 'rsa',
  $bits = 4096,
  $days = 3650,
) {

  validate_absolute_path($name)
  
  if $name =~ /^.*\.(.*)$/ {
    $extension = $1
  } else {
    $extension = undef
  }

  if $extension {
    $ssl_cert = $name
    $ssl_key = regsubst($name, "$extension", 'key', 'G')
    $ssl_cmd = regsubst($name, "$extension", 'sh', 'G')
  } else {
    $ssl_cert = "$name.crt"
    $ssl_key = "$name.key" 
    $ssl_cmd = "$name.sh"
  }

  $subject = join(['',
    "C=$country",
    "ST=$state",
    "L=$city",
    "O=$organization",
    "OU=$organization_unit",
    "CN=$common_name",
  ], '/')

  $cmd = join([
    $openssl_bin,
    "req",
    "-new",
    "-newkey $type:$bits",
    "-days $days",
    "-nodes",
    "-x509",
    "-subj '$subject'",
    "-keyout $ssl_key",
    "-out $ssl_cert",
  ], ' ')

  file { $ssl_cmd:
    ensure  => file,
    notify  => Exec[$cmd],
    content => $cmd,
  } 

  exec { $cmd:
    refreshonly => true,
  }

  file { [$ssl_cert, $ssl_key]:
    mode    => 0600,
    owner   => $owner,
    group   => $group,
    require => Exec[$cmd],
  }
}
