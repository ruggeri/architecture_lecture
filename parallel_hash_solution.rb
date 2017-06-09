require 'thread'
require 'digest/md5'

# For motivation on why you might want to do all this hashing, see:
# https://en.wikipedia.org/wiki/Hashcash

Thread::abort_on_exception = true

t1 = Time.now

MAXIMUM = (2 ** 128) - 1
DIFFICULTY = 1_000_000
GOAL = (MAXIMUM / DIFFICULTY)
NUM_HASHES = 5

NUM_THREADS = 256

def start_thread(thread_idx, queue)
  thr = Thread.new do
    value = "#{thread_idx}"
    while true
      hash = Digest::MD5.hexdigest(value).to_i(16)
      if hash < GOAL
        queue << hash
      end

      value = hash.to_s
    end
  end

  return thr
end

# queue lets you push and shift. Importantly queue is "thread safe".
# That means workers can push and the main thread can shift.
queue = Queue.new
threads = []
NUM_THREADS.times { |thread_idx| threads << start_thread(thread_idx, queue) }
NUM_HASHES.times do
  hash = queue.shift
  puts hash
end

threads.each { |thr| thr.kill }

t2 = Time.now
puts t2 - t1
