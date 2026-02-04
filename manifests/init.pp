# paw_ansible_role_memcached
# @summary Manage paw_ansible_role_memcached configuration
#
# @param ansible_managed
# @param memcached_threads
# @param memcached_log_file
# @param memcached_log_verbosity
# @param memcached_memory_limit
# @param memcached_port
# @param memcached_user
# @param memcached_listen_ip
# @param ip
# @param memcached_connections
# @param memcached_max_item_size
# @param par_vardir Base directory for Puppet agent cache (uses lookup('paw::par_vardir') for common config)
# @param par_tags An array of Ansible tags to execute (optional)
# @param par_skip_tags An array of Ansible tags to skip (optional)
# @param par_start_at_task The name of the task to start execution at (optional)
# @param par_limit Limit playbook execution to specific hosts (optional)
# @param par_verbose Enable verbose output from Ansible (optional)
# @param par_check_mode Run Ansible in check mode (dry-run) (optional)
# @param par_timeout Timeout in seconds for playbook execution (optional)
# @param par_user Remote user to use for Ansible connections (optional)
# @param par_env_vars Additional environment variables for ansible-playbook execution (optional)
# @param par_logoutput Control whether playbook output is displayed in Puppet logs (optional)
# @param par_exclusive Serialize playbook execution using a lock file (optional)
class paw_ansible_role_memcached (
  Optional[String] $ansible_managed = undef,
  Integer $memcached_threads = 4,
  String $memcached_log_file = '/var/log/memcached.log',
  Optional[String] $memcached_log_verbosity = undef,
  Integer $memcached_memory_limit = 64,
  Integer $memcached_port = 11211,
  Optional[String] $memcached_user = undef,
  String $memcached_listen_ip = '127.0.0.1',
  Optional[String] $ip = undef,
  Integer $memcached_connections = 1024,
  String $memcached_max_item_size = '1m',
  Optional[Stdlib::Absolutepath] $par_vardir = undef,
  Optional[Array[String]] $par_tags = undef,
  Optional[Array[String]] $par_skip_tags = undef,
  Optional[String] $par_start_at_task = undef,
  Optional[String] $par_limit = undef,
  Optional[Boolean] $par_verbose = undef,
  Optional[Boolean] $par_check_mode = undef,
  Optional[Integer] $par_timeout = undef,
  Optional[String] $par_user = undef,
  Optional[Hash] $par_env_vars = undef,
  Optional[Boolean] $par_logoutput = undef,
  Optional[Boolean] $par_exclusive = undef
) {
# Execute the Ansible role using PAR (Puppet Ansible Runner)
# Playbook synced via pluginsync to agent's cache directory
# Check for common paw::par_vardir setting, then module-specific, then default
$_par_vardir = $par_vardir ? {
  undef   => lookup('paw::par_vardir', Stdlib::Absolutepath, 'first', '/opt/puppetlabs/puppet/cache'),
  default => $par_vardir,
}
$playbook_path = "${_par_vardir}/lib/puppet_x/ansible_modules/ansible_role_memcached/playbook.yml"

par { 'paw_ansible_role_memcached-main':
  ensure        => present,
  playbook      => $playbook_path,
  playbook_vars => {
        'ansible_managed' => $ansible_managed,
        'memcached_threads' => $memcached_threads,
        'memcached_log_file' => $memcached_log_file,
        'memcached_log_verbosity' => $memcached_log_verbosity,
        'memcached_memory_limit' => $memcached_memory_limit,
        'memcached_port' => $memcached_port,
        'memcached_user' => $memcached_user,
        'memcached_listen_ip' => $memcached_listen_ip,
        'ip' => $ip,
        'memcached_connections' => $memcached_connections,
        'memcached_max_item_size' => $memcached_max_item_size
              },
  tags          => $par_tags,
  skip_tags     => $par_skip_tags,
  start_at_task => $par_start_at_task,
  limit         => $par_limit,
  verbose       => $par_verbose,
  check_mode    => $par_check_mode,
  timeout       => $par_timeout,
  user          => $par_user,
  env_vars      => $par_env_vars,
  logoutput     => $par_logoutput,
  exclusive     => $par_exclusive,
}
}
