# TCP Server: reverse echo server.

require 'socket'

server = TCPServer.new(8888)

# Using MRI, there is no parallelism. But there is "concurrency".
def run_worker_thread(connection)
  Thread.new do
    puts "Client thread spawned!"
    value = connection.gets.chomp
    connection.puts value.reverse
    connection.close
  end
end

while true
  connection = server.accept
  run_worker_thread(connection)
end
