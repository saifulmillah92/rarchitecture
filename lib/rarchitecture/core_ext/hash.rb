# frozen_string_literal: true

class Hash
  def as_struct
    keys = self.keys
    values = self.values.map do |v|
      case v
      when Hash then v.as_struct
      when Array then v.map { |e| e.is_a?(Hash) ? e.as_struct : e }
      else v
      end
    end

    Struct.new(*keys.map(&:to_sym)).new(*values)
  end
end
