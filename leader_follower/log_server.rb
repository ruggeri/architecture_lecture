require 'socket'

class LogServer
  def initialize(data_store, port)
    @data_store = data_store
    @log_server = TCPServer.new(port)
  end

  def run!
    @thread = Thread.new do
      while true
        handle_follower!(@log_server.accept)
      end
    end
  end
  
  def join
    @thread.join
  end

  def handle_follower!(connection)
    Thread.new do
      log_position = 0
      while true
        new_log_lines = @data_store.get_new_log_lines(log_position)
        new_log_lines.each do |log_line|
          raise "nil log line?" if log_line.nil?
          connection.puts log_line
        end

        log_position += new_log_lines.count

        sleep 1.0
      end
    end
  end
end
