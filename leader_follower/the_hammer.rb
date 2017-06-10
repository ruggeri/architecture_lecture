require 'socket'

Thread::abort_on_exception = true

def hammer_server
  socket = TCPSocket.new("localhost", 8080)
  
  100.times do |idx|
    if rand() < 0.50
      socket.puts "INCREMENT 123"
      socket.gets
    else
      socket.puts "SQUARE 123"
      socket.gets
    end
  end
  
  socket.close
end

100.times do |idx|
  puts "ROUND: #{idx}"

  threads = []
  10.times do
    threads << Thread.new { hammer_server }
  end

  threads.each { |thr| thr.join }
end
