# Puppet task for executing Ansible role: ansible_role_memcached
# This script runs the entire role via ansible-playbook

$ErrorActionPreference = 'Stop'

# Determine the ansible modules directory
if ($env:PT__installdir) {
  $AnsibleDir = Join-Path $env:PT__installdir "lib\puppet_x\ansible_modules\ansible_role_memcached"
} else {
  # Fallback to Puppet cache directory
  $AnsibleDir = "C:\ProgramData\PuppetLabs\puppet\cache\lib\puppet_x\ansible_modules\ansible_role_memcached"
}

# Check if ansible-playbook is available
$AnsiblePlaybook = Get-Command ansible-playbook -ErrorAction SilentlyContinue
if (-not $AnsiblePlaybook) {
  $result = @{
    _error = @{
      msg = "ansible-playbook command not found. Please install Ansible."
      kind = "puppet-ansible-converter/ansible-not-found"
    }
  }
  Write-Output ($result | ConvertTo-Json)
  exit 1
}

# Check if the role directory exists
if (-not (Test-Path $AnsibleDir)) {
  $result = @{
    _error = @{
      msg = "Ansible role directory not found: $AnsibleDir"
      kind = "puppet-ansible-converter/role-not-found"
    }
  }
  Write-Output ($result | ConvertTo-Json)
  exit 1
}

# Detect playbook location (collection vs standalone)
# Collections: ansible_modules/collection_name/roles/role_name/playbook.yml
# Standalone: ansible_modules/role_name/playbook.yml
$CollectionPlaybook = Join-Path $AnsibleDir "roles\paw_ansible_role_memcached\playbook.yml"
$StandalonePlaybook = Join-Path $AnsibleDir "playbook.yml"

if ((Test-Path (Join-Path $AnsibleDir "roles")) -and (Test-Path $CollectionPlaybook)) {
  # Collection structure
  $PlaybookPath = $CollectionPlaybook
  $PlaybookDir = Join-Path $AnsibleDir "roles\paw_ansible_role_memcached"
} elseif (Test-Path $StandalonePlaybook) {
  # Standalone role structure
  $PlaybookPath = $StandalonePlaybook
  $PlaybookDir = $AnsibleDir
} else {
  $result = @{
    _error = @{
      msg = "playbook.yml not found in $AnsibleDir or $AnsibleDir\roles\paw_ansible_role_memcached"
      kind = "puppet-ansible-converter/playbook-not-found"
    }
  }
  Write-Output ($result | ConvertTo-Json)
  exit 1
}

# Build extra-vars from PT_* environment variables
$ExtraVars = @{}
if ($env:PT_ansible_managed) {
  $ExtraVars['ansible_managed'] = $env:PT_ansible_managed
}
if ($env:PT_memcached_threads) {
  $ExtraVars['memcached_threads'] = $env:PT_memcached_threads
}
if ($env:PT_memcached_log_file) {
  $ExtraVars['memcached_log_file'] = $env:PT_memcached_log_file
}
if ($env:PT_memcached_log_verbosity) {
  $ExtraVars['memcached_log_verbosity'] = $env:PT_memcached_log_verbosity
}
if ($env:PT_memcached_memory_limit) {
  $ExtraVars['memcached_memory_limit'] = $env:PT_memcached_memory_limit
}
if ($env:PT_memcached_port) {
  $ExtraVars['memcached_port'] = $env:PT_memcached_port
}
if ($env:PT_memcached_user) {
  $ExtraVars['memcached_user'] = $env:PT_memcached_user
}
if ($env:PT_memcached_listen_ip) {
  $ExtraVars['memcached_listen_ip'] = $env:PT_memcached_listen_ip
}
if ($env:PT_ip) {
  $ExtraVars['ip'] = $env:PT_ip
}
if ($env:PT_memcached_connections) {
  $ExtraVars['memcached_connections'] = $env:PT_memcached_connections
}
if ($env:PT_memcached_max_item_size) {
  $ExtraVars['memcached_max_item_size'] = $env:PT_memcached_max_item_size
}

$ExtraVarsJson = $ExtraVars | ConvertTo-Json -Compress

# Execute ansible-playbook with the role
Push-Location $PlaybookDir
try {
  ansible-playbook playbook.yml `
    --extra-vars $ExtraVarsJson `
    --connection=local `
    --inventory=localhost, `
    2>&1 | Write-Output
  
  $ExitCode = $LASTEXITCODE
  
  if ($ExitCode -eq 0) {
    $result = @{
      status = "success"
      role = "ansible_role_memcached"
    }
  } else {
    $result = @{
      status = "failed"
      role = "ansible_role_memcached"
      exit_code = $ExitCode
    }
  }
  
  Write-Output ($result | ConvertTo-Json)
  exit $ExitCode
}
finally {
  Pop-Location
}
