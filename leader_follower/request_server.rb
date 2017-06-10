require_relative 'data_store'
require 'socket'

class RequestServer
  def initialize(data_store, port, read_only:)
    @data_store = data_store
    @request_server = TCPServer.new(port)
    @read_only = read_only
    @thread = nil
  end

  def run!
    @thread = Thread.new do
      while true
        connection = @request_server.accept
        Thread.new { handle_client_connection!(connection) }
      end
    end
  end

  def join
    @thread.join
  end

  def handle_client_connection!(connection)
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
      connection.puts "ERROR: UnknownCommandException: #{command}"
    rescue ReadOnlyException
      connection.puts "ERROR: Follower server cannot run command: #{command}"
    end
  end
end
