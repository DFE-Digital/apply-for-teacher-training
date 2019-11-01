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
        "#{values[0] || 'nil'} → #{values[1] || 'nil'}"
      else
        values.to_s
      end
    end

    def style
      last_change ? 'border: none' : ''
    end

    attr_reader :values, :attribute, :last_change
  end
end
