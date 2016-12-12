# {{ ansible_managed }}

# Min and Max threads per worker
threads 6, {{ mnohub_config.puma_worker_threads }}

app_dir = File.expand_path("../..", __FILE__)
shared_dir = "{{ deploy_directory }}/shared"

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env
port 3000
preload_app!

# Logging
stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

# Set master PID and state locations
pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"
activate_control_app
