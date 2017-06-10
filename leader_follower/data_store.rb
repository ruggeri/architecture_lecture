require 'thread'

class UnknownCommandException < Exception; end
class ReadOnlyException < Exception; end

class DataStore
  def initialize
    @data = Hash.new(0)
  end

  def increment(key)
    @data[key] += 1
  end

  def square(key)
    @data[key] *= @data[key]
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

  def get_log_lines(start_position)
    # TODO: implement with followers.
  end
end
