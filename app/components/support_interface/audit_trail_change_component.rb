module SupportInterface
  class AuditTrailChangeComponent < ViewComponent::Base
    include ViewHelper

    REDACTED_ATTRIBUTES = %w[
      sex disabilities ethnic_group ethnic_background
      hesa_sex hesa_disabilities hesa_ethnicity
    ].freeze

    def initialize(attribute:, values:, last_change:)
      @attribute = attribute
      @values = values
      @last_change = last_change
    end

    def format_audit_values
      return '[REDACTED]' if REDACTED_ATTRIBUTES.include?(@attribute)
      return values.map { |v| redact_equality_and_diversity_data(v) || 'nil' }.join(' → ') if values.is_a?(Array)

      redact_equality_and_diversity_data(values) || 'nil'
    end

    def style
      last_change ? 'border: none' : ''
    end

    def redact_equality_and_diversity_data(value)
      return value unless value.is_a? Hash

      REDACTED_ATTRIBUTES.each do |field|
        next unless value[field]

        value[field] = '[REDACTED]'
      end

      value
    end

    attr_reader :values, :attribute, :last_change
  end
end
