#!/bin/bash
set -e

# Puppet task for executing Ansible role: ansible_role_memcached
# This script runs the entire role via ansible-playbook

# Determine the ansible modules directory
if [ -n "$PT__installdir" ]; then
  ANSIBLE_DIR="$PT__installdir/lib/puppet_x/ansible_modules/ansible_role_memcached"
else
  # Fallback to /opt/puppetlabs/puppet/cache/lib/puppet_x/ansible_modules
  ANSIBLE_DIR="/opt/puppetlabs/puppet/cache/lib/puppet_x/ansible_modules/ansible_role_memcached"
fi

# Check if ansible-playbook is available
if ! command -v ansible-playbook &> /dev/null; then
  echo '{"_error": {"msg": "ansible-playbook command not found. Please install Ansible.", "kind": "puppet-ansible-converter/ansible-not-found"}}'
  exit 1
fi

# Check if the role directory exists
if [ ! -d "$ANSIBLE_DIR" ]; then
  echo "{\"_error\": {\"msg\": \"Ansible role directory not found: $ANSIBLE_DIR\", \"kind\": \"puppet-ansible-converter/role-not-found\"}}"
  exit 1
fi

# Detect playbook location (collection vs standalone)
# Collections: ansible_modules/collection_name/roles/role_name/playbook.yml
# Standalone: ansible_modules/role_name/playbook.yml
if [ -d "$ANSIBLE_DIR/roles" ] && [ -f "$ANSIBLE_DIR/roles/paw_ansible_role_memcached/playbook.yml" ]; then
  # Collection structure
  PLAYBOOK_PATH="$ANSIBLE_DIR/roles/paw_ansible_role_memcached/playbook.yml"
  PLAYBOOK_DIR="$ANSIBLE_DIR/roles/paw_ansible_role_memcached"
elif [ -f "$ANSIBLE_DIR/playbook.yml" ]; then
  # Standalone role structure
  PLAYBOOK_PATH="$ANSIBLE_DIR/playbook.yml"
  PLAYBOOK_DIR="$ANSIBLE_DIR"
else
  echo "{\"_error\": {\"msg\": \"playbook.yml not found in $ANSIBLE_DIR or $ANSIBLE_DIR/roles/paw_ansible_role_memcached\", \"kind\": \"puppet-ansible-converter/playbook-not-found\"}}"
  exit 1
fi

# Build extra-vars from PT_* environment variables (excluding par_* control params)
EXTRA_VARS="{"
FIRST=true
if [ -n "$PT_ansible_managed" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"ansible_managed\": \"$PT_ansible_managed\""
fi
if [ -n "$PT_memcached_threads" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"memcached_threads\": \"$PT_memcached_threads\""
fi
if [ -n "$PT_memcached_log_file" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"memcached_log_file\": \"$PT_memcached_log_file\""
fi
if [ -n "$PT_memcached_log_verbosity" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"memcached_log_verbosity\": \"$PT_memcached_log_verbosity\""
fi
if [ -n "$PT_memcached_memory_limit" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"memcached_memory_limit\": \"$PT_memcached_memory_limit\""
fi
if [ -n "$PT_memcached_port" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"memcached_port\": \"$PT_memcached_port\""
fi
if [ -n "$PT_memcached_user" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"memcached_user\": \"$PT_memcached_user\""
fi
if [ -n "$PT_memcached_listen_ip" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"memcached_listen_ip\": \"$PT_memcached_listen_ip\""
fi
if [ -n "$PT_ip" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"ip\": \"$PT_ip\""
fi
if [ -n "$PT_memcached_connections" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"memcached_connections\": \"$PT_memcached_connections\""
fi
if [ -n "$PT_memcached_max_item_size" ]; then
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    EXTRA_VARS="$EXTRA_VARS,"
  fi
  EXTRA_VARS="$EXTRA_VARS\"memcached_max_item_size\": \"$PT_memcached_max_item_size\""
fi
EXTRA_VARS="$EXTRA_VARS}"

# Build ansible-playbook command matching PAR provider exactly
# See: https://github.com/garrettrowell/puppet-par/blob/main/lib/puppet/provider/par/par.rb#L166
cd "$PLAYBOOK_DIR"

# Base command with inventory and connection (matching PAR)
ANSIBLE_CMD="ansible-playbook -i localhost, --connection=local"

# Add extra-vars (playbook variables)
ANSIBLE_CMD="$ANSIBLE_CMD -e \"$EXTRA_VARS\""

# Add tags if specified
if [ -n "$PT_par_tags" ]; then
  TAGS=$(echo "$PT_par_tags" | sed 's/\[//;s/\]//;s/"//g;s/,/,/g')
  ANSIBLE_CMD="$ANSIBLE_CMD --tags \"$TAGS\""
fi

# Add skip-tags if specified
if [ -n "$PT_par_skip_tags" ]; then
  SKIP_TAGS=$(echo "$PT_par_skip_tags" | sed 's/\[//;s/\]//;s/"//g;s/,/,/g')
  ANSIBLE_CMD="$ANSIBLE_CMD --skip-tags \"$SKIP_TAGS\""
fi

# Add start-at-task if specified
if [ -n "$PT_par_start_at_task" ]; then
  ANSIBLE_CMD="$ANSIBLE_CMD --start-at-task \"$PT_par_start_at_task\""
fi

# Add limit if specified
if [ -n "$PT_par_limit" ]; then
  ANSIBLE_CMD="$ANSIBLE_CMD --limit \"$PT_par_limit\""
fi

# Add verbose flag if specified
if [ "$PT_par_verbose" = "true" ]; then
  ANSIBLE_CMD="$ANSIBLE_CMD -v"
fi

# Add check mode flag if specified
if [ "$PT_par_check_mode" = "true" ]; then
  ANSIBLE_CMD="$ANSIBLE_CMD --check"
fi

# Add user if specified
if [ -n "$PT_par_user" ]; then
  ANSIBLE_CMD="$ANSIBLE_CMD --user \"$PT_par_user\""
fi

# Add timeout if specified
if [ -n "$PT_par_timeout" ]; then
  ANSIBLE_CMD="$ANSIBLE_CMD --timeout $PT_par_timeout"
fi

# Add playbook path as last argument (matching PAR)
ANSIBLE_CMD="$ANSIBLE_CMD playbook.yml"

# Set environment variables if specified (matching PAR env_vars handling)
if [ -n "$PT_par_env_vars" ]; then
  # Parse JSON hash and export variables
  eval $(echo "$PT_par_env_vars" | sed 's/[{}]//g;s/": "/=/g;s/","/;export /g;s/"//g' | sed 's/^/export /')
fi

# Set required Ansible environment (matching PAR)
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export ANSIBLE_STDOUT_CALLBACK=json

# Execute ansible-playbook
eval $ANSIBLE_CMD 2>&1

EXIT_CODE=$?

# Return JSON result
if [ $EXIT_CODE -eq 0 ]; then
  echo '{"status": "success", "role": "ansible_role_memcached"}'
else
  echo "{\"status\": \"failed\", \"role\": \"ansible_role_memcached\", \"exit_code\": $EXIT_CODE}"
fi

exit $EXIT_CODE
