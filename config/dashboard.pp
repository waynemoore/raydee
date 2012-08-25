# Packages to install
package { 'git':
  ensure => present
}

package { 'zlib1g-dev':
  ensure => present
}

package { 'g++':
  ensure => present
}

package { 'libxml2-dev':
  ensure => present
}

package { 'libxslt1-dev':
  ensure => present
}

package { 'libssl-dev':
  ensure => present
}

# Low diskspace, can remove these
package { 'thunderbird':
  ensure => absent
}

package { 'firefox':
  ensure => absent
}

package { 'gimp':
  ensure => absent
}

package { 'abiword':
  ensure => absent
}

package { 'pidgin':
  ensure => absent
}