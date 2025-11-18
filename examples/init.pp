# Example usage of paw_ansible_role_memcached

# Simple include with default parameters
include paw_ansible_role_memcached

# Or with custom parameters:
# class { 'paw_ansible_role_memcached':
#   ansible_managed => undef,
#   memcached_threads => 4,
#   memcached_log_file => '/var/log/memcached.log',
#   memcached_log_verbosity => undef,
#   memcached_memory_limit => 64,
#   memcached_port => 11211,
#   memcached_user => undef,
#   memcached_listen_ip => '127.0.0.1',
#   ip => undef,
#   memcached_connections => 1024,
#   memcached_max_item_size => '1m',
# }
