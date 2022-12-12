require 'factory_bot_rails'

module Satisfactory
  class Loader
    def self.factory_configurations
      FactoryBot.factories.each.with_object({}) do |factory, hash|
        next unless (model = factory.build_class)
        next unless model < ApplicationRecord

        all_associations = model.reflect_on_all_associations.reject(&:polymorphic?)
        plural_associations = model.reflect_on_all_associations(:has_many)
        singular_associations = all_associations - plural_associations

        config = {
          name: factory.name,
          factory:,
          traits: factory.defined_traits.map(&:name),
          model:,
          associations: {
            singular: singular_associations.map(&:name),
            plural: plural_associations.map(&:name),
          },
        }

        config[:type] = Satisfactory::Type.define_from(config)

        hash[factory.name] = config
      end
    end
  end
end
