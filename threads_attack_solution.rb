require 'concurrent'
require 'thread'

NUM_TIMES = 1_000_000

class MyLock
  def initialize
    @wants_to_enter1 = Concurrent::AtomicBoolean.new(false)
    @wants_to_enter2 = Concurrent::AtomicBoolean.new(false)
    
    @turn = 1
  end

  def lock1
    @wants_to_enter1.make_true
    @turn = 2
    while @wants_to_enter2.true? && (@turn == 2)
      # Busy wait
    end
  end

  def unlock1
    @wants_to_enter1.make_false
  end

  def lock2
    @wants_to_enter2.make_true
    @turn = 1
    while @wants_to_enter1.true? && (@turn == 1)
      # Busy wait
    end
  end

  def unlock2
    @wants_to_enter2.make_false
  end
end

lock = MyLock.new
i = 0

thr1 = Thread.new do
  NUM_TIMES.times do
    lock.lock1
    i = i + 1
    lock.unlock1
  end
end

thr2 = Thread.new do
  NUM_TIMES.times do
    lock.lock2
    i = i + 1
    lock.unlock2
  end
end

thr1.join
thr2.join

puts i