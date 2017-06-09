require 'concurrent'
require 'thread'

NUM_ITERS = 1_000_000

# Data race
class MyMutex
  def initialize
    @thread1_wants_lock = Concurrent::AtomicBoolean.new(false)
    @thread2_wants_lock = Concurrent::AtomicBoolean.new(false)
    @turn = Concurrent::AtomicFixnum.new(0)
  end
  
  def lock(thread_idx)
    # "Spinlock"

    if thread_idx == 1
      @thread1_wants_lock = true
      # @thread1_wants_lock.make_true
      @turn.value = 2
      while @thread2_wants_lock && (@turn.value == 2)
        # Busy loop
      end
    else
      @thread2_wants_lock = true
      # @thread2_wants_lock.make_true
      @turn.value = 1
      while @thread1_wants_lock && (@turn.value == 1)
        # Busy loop
      end
    end
  end
  
  def unlock(thread_idx)
    if thread_idx == 1
      @thread1_wants_lock.make_false
    else
      @thread2_wants_lock.make_false
    end
  end
end

i = 0
lock_for_i = MyMutex.new

thr1 = Thread.new do
  NUM_ITERS.times do
    lock_for_i.lock(1)
    i = i + 1
    lock_for_i.unlock(1)
  end
end

thr2 = Thread.new do
  NUM_ITERS.times do
    lock_for_i.lock(2)
    i = i + 1
    lock_for_i.unlock(2)
  end 
end

thr1.join
thr2.join

puts i