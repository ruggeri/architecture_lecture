require 'socket'

class LogClient
  def initialize(data_store, log_server_port)
    @data_store = data_store
    @log_connection = TCPSocket.new("localhost", log_server_port)
  end
  
  def run!
    @thread = Thread.new do
      while true
        command, key = @log_connection.gets.chomp.split
        puts "Received Log Line: #{command} #{key}"
        @data_store.perform_command(command, key, read_only: false)
      end
    end
  end

  def join
    @thread.join
  end
end
