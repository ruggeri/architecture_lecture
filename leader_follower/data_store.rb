require 'thread'

class UnknownCommandException < Exception; end
class ReadOnlyException < Exception; end

# Make DataStore thread safe.
class DataStore
  def initialize
    @data = Hash.new(0)
    @log_lines = []
    @mutex = Mutex.new
  end

  def increment(key)
    @mutex.synchronize do
      @data[key] = (@data[key] + 1) % 1_000_000
      @log_lines << "INCREMENT #{key}"
    end
  end

  def square(key)
    @mutex.synchronize do
      @data[key] = (@data[key] * @data[key]) % 1_000_000
      @log_lines << "SQUARE #{key}"
    end
  end

  def get(key)
    @mutex.synchronize do
      return @data[key]
    end
  end

  def perform_command(command, key, read_only:)
    if command == "GET"
      return get(key)
    elsif command == "INCREMENT"
      raise ReadOnlyException if read_only
      increment(key)
      return "OK"
    elsif command == "SQUARE"
      raise ReadOnlyException if read_only
      square(key)
      return "OK"
    else
      raise UnknownCommandException
    end
  end

  def get_new_log_lines(start_position)
    new_log_lines = []
    position = start_position
    @mutex.synchronize do
      while position < @log_lines.length
        new_log_lines << @log_lines[position]
        position += 1
      end
    end

    return new_log_lines
  end
end
