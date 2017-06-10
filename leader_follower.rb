require 'socket'

Thread::abort_on_exception = true

class UnknownCommandException < Exception; end
class ReadOnlyException < Exception; end

class DataStore
  def initialize
    @mutex = Mutex.new
    @data = Hash.new(0)
    @log_lines = []
  end

  def increment(key)
    @mutex.synchronize do
      @data[key] += 1
      @log_lines << "INCREMENT #{key}"
      return "OK"
    end
  end

  def square(key)
    @mutex.synchronize do
      @data[key] *= @data[key]
      @log_lines << "SQUARE #{key}"
      return "OK"
    end
  end

  def get(key)
    @mutex.synchronize { return @data[key] }
  end
  
  def perform_command(command, key, read_only:)
    if command == "GET"
      return get(key)
    elsif command == "INCREMENT"
      raise ReadOnlyException if read_only
      return increment(key)
    elsif command == "SQUARE"
      raise ReadOnlyException if read_only
      return square(key)
    else
      raise UnknownCommandException
    end
  end

  def get_log_lines(start_position)
    @mutex.synchronize do
      result = []

      position = start_position
      (start_position...(@log_lines.length)).each do |idx|
        result << @log_lines[idx]
      end
      
      return result
    end
  end
end

class RequestServer
  def initialize(data_store, port, read_only:)
    @data_store = data_store
    @client_server = TCPServer.new(port)
    @read_only = read_only
    @thread = nil
  end

  def run!
    @thread = Thread.new do
      while true
        connection = @client_server.accept
        Thread.new { handle_client_request!(connection) }
      end
    end
  end

  def join
    @thread.join
  end

  def handle_client_request!(connection)
    while true
      input = connection.gets
      break if input.nil?
      command, key = input.chomp.split
      handle_command(connection, command, key)
    end

    connection.close
  end
  
  def handle_command(connection, command, key)
    begin
      result = @data_store.perform_command(command, key, read_only: @read_only)
      connection.puts result
    rescue UnknownCommandException
      connection.puts "ERROR: UNKNOWN COMMAND #{command}"
    rescue ReadOnlyException
      connection.puts "ERROR: READ ONLY FOLLOWER"
    end
  end
end

class LogServer
  def initialize(data_store, port)
    @data_store = data_store
    @log_server = TCPServer.new(port)
    @thread = nil
  end

  def run!
    @thread = Thread.new do
      while true
        connection = @log_server.accept
        Thread.new { handle_follower!(connection) }
      end
    end
  end
  
  def join
    @thread.join
  end

  def handle_follower!(connection)
    log_position = 0
    while true
      new_log_lines = @data_store.get_log_lines(log_position)
      new_log_lines.each do |log_line|
        connection.puts log_line
      end

      log_position += new_log_lines.count

      sleep 1.00
    end
  end
end

class LogClient
  def initialize(data_store, port)
    @data_store = data_store
    @log_connection = TCPSocket.new("localhost", port)
    @thread = nil
  end
  
  def run!
    @thread = Thread.new do
      while true
        command, key = @log_connection.gets.chomp.split
        @data_store.perform_command(command, key, read_only: false)
      end
    end
  end

  def join
    @thread.join
  end
end

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
