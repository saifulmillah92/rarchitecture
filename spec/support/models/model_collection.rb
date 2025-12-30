# frozen_string_literal: true

class ModelCollection < Array
  attr_reader :klass

  def initialize(array, klass)
    super(array)
    @klass = klass
  end

  # Mimic ActiveRecord's .find(id)
  def find(id)
    results = select { |record| record.id.to_i == id.to_i }
    results.first
  end

  # Mimic ActiveRecord's .find_by(attributes)
  def find_by(arg)
    results = select { |record| arg.all? { |k, v| record.send(k).to_s == v.to_s } }
    results.first
  end

  # Mimic ActiveRecord's .where(attributes)
  def where(query, *args)
    results =
      case query
      when Hash then filter_by_hash(query)
      when String then query.include?("LOWER") ? filter_by_lower(query, args.first) : self
      else self
      end

    ModelCollection.new(results, @klass)
  end

  # Mimic ActiveRecord's .limit(value)
  def limit(num)
    ModelCollection.new(first(num), @klass)
  end

  # Mimic ActiveRecord's .offset(value)
  def offset(num)
    ModelCollection.new(drop(num), @klass)
  end

  # Mimic ActiveRecord's .reorder(value)
  def reorder(column, direction)
    sort! { |a, b| compare_values(a.send(column), b.send(column), direction) }
    self
  end

  def arel_table    = @klass.arel_table
  def column(name)  = @klass.arel_table[name]
  def column_names  = @klass.column_names
  def limit_value   = nil

  private

  def filter_by_hash(query)
    select do |record|
      query.all? { |key, value| record.send(key).to_s == value.to_s }
    end
  end

  def filter_by_lower(query, arg)
    attr_name = query.match(/LOWER\(.*\.(\w+)\)/)[1]
    value     = arg.to_s.downcase

    select { |record| record.send(attr_name).to_s.downcase == value }
  end

  def compare_values(val_a, val_b, direction)
    return 1  if val_a.nil?
    return -1 if val_b.nil?

    comparison = val_a <=> val_b
    direction == "desc" ? -comparison : comparison
  end
end
