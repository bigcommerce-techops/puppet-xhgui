# Installs MongoDB and creates indexes for XHGui
class xhgui::mongo(
  $php_mongo_package,
  $mongo_host,
  $mongo_db,
) {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin' ] }

  if !defined(Package[$php_mongo_package]) {
    package { $php_mongo_package:
      ensure => present
    }
  }

  if !defined(Package['mongodb-clients']) {
    package {'mongodb-clients':
      ensure => present,
    }
  }

  # Add mongo indexes
  exec { 'mongo indexes':
    command   => "mongo ${mongo_host}/${mongo_db} --eval \"db.results.ensureIndex( { 'meta.SERVER.REQUEST_TIME' : -1 } );
      db.results.ensureIndex( { 'profile.main().wt' : -1 } );
      db.results.ensureIndex( { 'profile.main().mu' : -1 } );
      db.results.ensureIndex( { 'profile.main().cpu' : -1 } );
      db.results.ensureIndex( { 'meta.url' : 1 } )\"",
      require => Package['mongodb-clients'],
    tries     => 10,  # Retry the Mongo command, as MongoDB takes a few seconds
    try_sleep => 2,   # to start (at least the first time)
  }
}
