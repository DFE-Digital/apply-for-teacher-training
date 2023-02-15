class Adviser::ModelTransformer
  class << self
    def get_attributes_as_snake_case(model)
      model.to_hash.transform_keys do |key|
        model.class.attribute_map.invert[key]
      end
    end
  end
end
