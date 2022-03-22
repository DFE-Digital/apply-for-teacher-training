module Bigquery
  module FieldList
    def self.blocklist
      Rails.configuration.analytics_blocklist
    end

    def self.allowlist
      Rails.configuration.analytics
    end

    def self.generate_blocklist
      diff_model_attributes_against(allowlist)[:missing]
    end

    def self.unlisted_fields
      diff_model_attributes_against(allowlist, blocklist)[:missing]
    end

    def self.surplus_fields
      diff_model_attributes_against(allowlist)[:surplus]
    end

    def self.diff_model_attributes_against(*lists)
      Rails.application.eager_load!
      ActiveRecord::Base.descendants
        .reject { |model| model.name.include? 'ActiveRecord' } # ignore internal AR classes
        .reduce({ missing: {}, surplus: {} }) do |diff, next_model|
          table_name = next_model.table_name&.to_sym

          if table_name.present?
            attributes_considered = lists.map do |list|
              # for each list of model attrs, look up the attrs for this model
              list.fetch(table_name, [])
            end.reduce(:concat) # then combine to get all the attrs we deal with

            missing_attributes = next_model.attribute_names - attributes_considered
            surplus_attributes = attributes_considered - next_model.attribute_names

            if missing_attributes.any?
              diff[:missing][table_name] = missing_attributes
            end

            if surplus_attributes.any?
              diff[:surplus][table_name] = surplus_attributes
            end
          end

          diff
        end
    end
  end
end
