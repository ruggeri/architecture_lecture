require_relative 'data_store'
require_relative 'log_client'
require_relative 'log_server'
require_relative 'request_server'

Thread::abort_on_exception = true

def run_leader!(request_server_port, log_server_port)
  data_store = DataStore.new
  request_server = RequestServer.new(data_store, request_server_port, read_only: false)
  log_server = LogServer.new(data_store, log_server_port)
  
  request_server.run!
  log_server.run!
  request_server.join
  log_server.join
end

def run_follower!(request_server_port, log_server_port)
  data_store = DataStore.new
  request_server = RequestServer.new(data_store, request_server_port, read_only: true)
  log_client = LogClient.new(data_store, log_server_port)

  request_server.run!
  log_client.run!
  request_server.join
  log_client.join
end

def main
  raise "[--leader|--follower] request_server_port log_server_port" unless ARGV.length == 3
  request_server_port = Integer(ARGV[1])
  log_server_port = Integer(ARGV[2])

  if ARGV[0] == "--leader"
    run_leader!(request_server_port, log_server_port)
  elsif ARGV[0] == "--follower"
    run_follower!(request_server_port, log_server_port)
  end
end

if $PROGRAM_NAME == __FILE__
  main
end
