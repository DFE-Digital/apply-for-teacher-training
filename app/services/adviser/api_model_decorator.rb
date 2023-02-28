class Adviser::APIModelDecorator < SimpleDelegator
  def attributes_as_snake_case
    to_hash.transform_keys do |key|
      __getobj__.class.attribute_map.invert[key]
    end
  end
end
