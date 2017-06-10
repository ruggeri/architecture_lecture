result = []

NUM_ITERS = 1_000

thr1 = Thread.new do
  NUM_ITERS.times { result << rand }
end

thr2 = Thread.new do
  NUM_ITERS.times { result << rand }
end

thr1.join
thr2.join

puts result.count