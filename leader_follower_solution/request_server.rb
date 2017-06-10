require_relative 'data_store'
require 'socket'

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
    puts "CLIENT CONNECTED"
    while true
      input = connection.gets
      break if input.nil?
      command, key = input.chomp.split
      puts "GOT COMMAND: #{command} #{key}"
      handle_command(connection, command, key)
    end

    connection.close
    puts "CLIENT DISCONNECTED"
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
