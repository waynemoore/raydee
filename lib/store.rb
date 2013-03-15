require 'yaml'
require 'json'


class InvalidIdException < Exception
end

class Store

  attr_accessor :name

  def initialize name
    @name = name
    @list = []
    @data = {}
  end

  def put item
    raise ArgumentError.new("Nil items not allowed") if item.nil?
    raise InvalidIdException if item.id.nil?

    @list << item.id unless @data.include? item.id
    @data[item.id] = item
    nil
  end

  def get id
    @data[id]
  end

  def items
    @list.collect { |id| @data[id] }
  end

  def size
    @list.size
  end

end
