require 'thread'

class UnknownCommandException < Exception; end
class ReadOnlyException < Exception; end

class DataStore
  def initialize
    @data = Hash.new(0)
    @log_lines = []
  end

  def increment(key)
    @data[key] += 1
    @log_lines << "INCREMENT #{key}"
  end

  def square(key)
    @data[key] *= @data[key]
    @log_lines << "SQUARE #{key}"
  end

  def get(key)
    return @data[key]
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
    while position < @log_lines.length
      new_log_lines << @log_lines[position]
      position += 1
    end
    
    return new_log_lines
  end
end
