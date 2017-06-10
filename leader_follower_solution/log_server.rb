require 'socket'

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
