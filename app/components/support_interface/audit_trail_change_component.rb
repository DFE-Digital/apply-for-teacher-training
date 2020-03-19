module SupportInterface
  class AuditTrailChangeComponent < ActionView::Component::Base
    include ViewHelper

    validates :attribute, presence: true
    validates :values, presence: true

    def initialize(attribute:, values:, last_change:)
      @attribute = attribute
      @values = values
      @last_change = last_change
    end

    def format_audit_values
      if values.is_a? Array
        before, after = values.map { |v| redact_equality_and_diversity_data(v) || 'nil' }
        "#{before} → #{after}"
      else
        redact_equality_and_diversity_data(values) || 'nil'
      end
    end

    def style
      last_change ? 'border: none' : ''
    end

    def redact_equality_and_diversity_data(value)
      return value unless value.is_a? Hash

      %w[sex disabilities ethnic_group ethnic_background].each do |field|
        next unless value[field]

        value[field] = '[REDACTED]'
      end

      value
    end

    attr_reader :values, :attribute, :last_change
  end
end
