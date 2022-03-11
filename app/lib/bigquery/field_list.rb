module Bigquery
  module FieldList
    def self.blocklist
      Rails.configuration.analytics_blocklist
    end

    def self.allowlist
      Rails.configuration.analytics
    end

    def self.generate_blocklist
      diff_model_attributes_against(allowlist)
    end

    def self.unlisted_fields
      diff_model_attributes_against(allowlist, blocklist)
    end

    def self.diff_model_attributes_against(*lists)
      Rails.application.eager_load!
      ActiveRecord::Base.descendants
        .reject { |model| model.name.include? 'ActiveRecord' } # ignore internal AR classes
        .reduce({}) do |unlisted, next_model|
          table_name = next_model.table_name&.to_sym

          if table_name.present?
            attributes_considered = lists.map do |list|
              # for each list of model attrs, look up the attrs for this model
              list.fetch(table_name, [])
            end.reduce(:concat) # then combine to get all the attrs we deal with

            missing_attributes = next_model.attribute_names - attributes_considered

            if missing_attributes.any?
              unlisted[table_name] = missing_attributes
            end
          end

          unlisted
        end
    end
  end
end
