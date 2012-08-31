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

  def put id, item
    raise InvalidIdException if id.nil?
    @list << id unless @data.include? id
    @data[id] = item
    nil
  end

  def get id
    @data[id]
  end

  def items
    @list.collect { |id| @data[id] }
  end

end
