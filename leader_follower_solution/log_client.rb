require 'socket'

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
        puts "RECEIVED LOG COMMAND: #{command} #{key}"
        @data_store.perform_command(command, key, read_only: false)
      end
    end
  end

  def join
    @thread.join
  end
end
