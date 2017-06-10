require 'thread'

class UnknownCommandException < Exception; end
class ReadOnlyException < Exception; end

class DataStore
  def initialize
    @mutex = Mutex.new
    @data = Hash.new(0)
    @log_lines = []
  end

  def increment(key)
    @mutex.synchronize do
      @data[key] += 1
      @log_lines << "INCREMENT #{key}"
      return "OK"
    end
  end

  def square(key)
    @mutex.synchronize do
      @data[key] *= @data[key]
      @log_lines << "SQUARE #{key}"
      return "OK"
    end
  end

  def get(key)
    @mutex.synchronize { return @data[key] }
  end
  
  def perform_command(command, key, read_only:)
    if command == "GET"
      return get(key)
    elsif command == "INCREMENT"
      raise ReadOnlyException if read_only
      return increment(key)
    elsif command == "SQUARE"
      raise ReadOnlyException if read_only
      return square(key)
    else
      raise UnknownCommandException
    end
  end

  def get_log_lines(start_position)
    @mutex.synchronize do
      result = []

      position = start_position
      (start_position...(@log_lines.length)).each do |idx|
        result << @log_lines[idx]
      end
      
      return result
    end
  end
end
