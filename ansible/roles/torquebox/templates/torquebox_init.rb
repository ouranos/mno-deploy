#!/usr/bin/env ruby

# Script to start/stop Torquebox
# Used by init scripts
#
# Start: torquebox_init.rb start
# Stop: torquebox_init.rb stop

require 'fileutils'
require 'net/http'
require 'logger'

PIDFOLDER = "/var/run/torquebox"
PIDFILE = "#{PIDFOLDER}/torquebox.pid"
LOGFOLDER = "/var/log/torquebox"
LOGFILE = "#{LOGFOLDER}/torquebox.log"
INIT_LOGFILE = "#{LOGFOLDER}/torquebox_init.log"

STARTTIME = 45
DIETIME = 30

HTTP_TIMEOUT = 5 #seconds

FileUtils.mkdir_p(PIDFOLDER) unless Dir.exists?(PIDFOLDER)
FileUtils.mkdir_p(LOGFOLDER) unless Dir.exists?(LOGFOLDER)

TORQUEBOX_START = "#{ENV['JBOSS_HOME']}/bin/standalone.sh"
TORQUEBOX_STOP = "#{ENV['JBOSS_HOME']}/bin/jboss-cli.sh --connect command=:shutdown"

# Node nickname
JBOSS_NODE = `hostname`.split('.')[0].chomp # myserver1.domain.com => myserver1

def logger
  @logger ||= Logger.new(INIT_LOGFILE)
end

def http_get(uri)
  http = Net::HTTP.new(uri.host, uri.port)
  http.open_timeout = HTTP_TIMEOUT
  http.read_timeout = HTTP_TIMEOUT
  res = http.get(uri.path)

  case res
  when Net::HTTPSuccess
    return res.body
  else
    logger.info "Error retrieving http://#{uri.host}#{uri.path}"
    return nil
  end
rescue Timeout::Error,Errno::ETIMEDOUT => e
  logger.info "URL http://#{uri.host}#{uri.path} not reachable. Skipping."
  return nil
end

def start_command
  raise("Environment variables missing: JBOSS_HOME and RACK_ENV") unless ENV['JBOSS_HOME'] && ENV['RACK_ENV']
  logger.info "Starting Torquebox home=#{ENV['JBOSS_HOME']}, environment=#{ENV['RACK_ENV']}, cluster=#{ENV['TORQUEBOX_CLUSTER']}"

  # Configure metadata endpoint
  metadata_endpoint = 'http://169.254.169.254/latest/meta-data/'
  local_ip = http_get(URI.parse(metadata_endpoint + 'local-ipv4')) || '127.0.0.1'

  if [nil, '', '0', 'false', 'False'].include?(ENV['TORQUEBOX_CLUSTER']) || local_ip == '127.0.0.1'
    # Start torquebox in standalone mode
    logger.info "Executing command: #{TORQUEBOX_START} --server-config=standalone.xml -b=0.0.0.0 >> #{LOGFILE} 2>&1"
    system("#{TORQUEBOX_START} --server-config=standalone.xml -b=0.0.0.0 >> #{LOGFILE} 2>&1")
  else
    # Start torquebox in cluster mode
    # Get AWS Public IP or fallback to local_ip
    public_ip = http_get(URI.parse(metadata_endpoint + 'public-ipv4')) || local_ip

    # Start Jboss
    cmd = "#{TORQUEBOX_START} --server-config=standalone-ha.xml -b=0.0.0.0 -Djgroups.bind_addr=#{local_ip} -Djgroups.external_addr=#{public_ip} -Djboss.node.name=#{JBOSS_NODE} >> #{LOGFILE} 2>&1"
    logger.info "Executing command: #{cmd}"
    system(cmd)
  end

  # Delete PID file when process exits
  File.delete(PIDFILE) if File.exist?(PIDFILE)
end

def stop_command
  logger.info "Stopping Torquebox #{ENV['JBOSS_HOME']}"
  system("#{TORQUEBOX_STOP} >> #{LOGFILE} 2>&1")
  sleep DIETIME
  if jboss_pid
    logger.error "Grace period expired. Killing process..."
    force_stop_command
  else
    File.delete(PIDFILE) if File.exist?(PIDFILE)
    logger.info "Successfully stopped Torquebox"
  end
end

def force_stop_command
  logger.info "Force Stopping Torquebox #{ENV['JBOSS_HOME']} with PID #{jboss_pid}"

  if jboss_pid
    Process.kill(9, jboss_pid)
    File.delete(PIDFILE) if File.exist?(PIDFILE)
    logger.info "#{Time.now}: Successfully stopped"
  else
    logger.error "Torquebox is not running"
  end
end

def jboss_pid
  pid = `ps -fu | grep torquebox | grep jboss-modules.jar | grep -v grep | awk {'print $2'}`
  pid == '' ? false : pid.chomp
end

def run
  start_command
end

def start
  pid = Process.fork{ start_command }
  Process.detach(pid)
  File.open(PIDFILE, 'w'){ |f| f.write(pid) }

  puts "Asked Torquebox to start"
end

def stop
  Process.fork{ stop_command }
  puts "Asked Torquebox to stop"
end

def kill
  puts "Killing torquebox..."
  Process.fork{ force_stop_command }
end

def status
  if pid = jboss_pid
    puts "Torquebox is running... (PID: #{pid})"
  else
    puts "Torquebox is stopped."
  end
end

# Execute script
command = ARGV[0]
case command
when 'run'
  run
when 'start'
  start
when 'stop'
  stop
when 'kill'
  kill
when 'restart'
  stop
  start
when 'status'
  status
else
  puts "Usage: torquebox_init.rb <start|stop|restart|kill|status>"
end
