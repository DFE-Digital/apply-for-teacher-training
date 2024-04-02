# When included in a model, it will create a method for each date field passed in that returns the number of days since
# the date field was set.

# For example, if you have a model with a field called `submitted_at`, you can call `days_since_submitted` on an
# instance of that model

# If you want to add a date field to a model, you can do so like this:
# class MyModel < ApplicationRecord
#   dateable :submitted_at, :updated_at
# end

module Dateable
  extend ActiveSupport::Concern

  included do
    def self.dateable(*date_fields)
      date_fields.each do |date_field|
        field_name = "#{date_field}_at"

        define_method("days_since_#{date_field}") do
          return unless send(field_name)

          (Time.zone.now - send(field_name)).seconds.in_days.round
        end
      end
    end
  end
end
