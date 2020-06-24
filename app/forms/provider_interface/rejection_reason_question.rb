module ProviderInterface
  class RejectionReasonQuestion
    include ActiveModel::Model

    attr_accessor :label
    attr_accessor :y_or_n
    attr_writer :reasons
    attr_accessor :explanation
    attr_accessor :answered
    attr_accessor :requires_reasons
    attr_accessor :additional_question

    validates :y_or_n, presence: true
    validate :enough_reasons?, if: -> { yes? }
    validate :reasons_all_valid?, if: -> { yes? }
    validate :explanation_valid?, if: -> { yes? && explanation.present? }

    def initialize(*args)
      super(*args)
      @requires_reasons ||= reasons.count.positive?
    end

    def reasons
      @reasons ||= []
    end

    def enough_reasons?
      if requires_reasons && reasons.select(&:selected?).count.zero?
        errors.add(:reasons, 'Please give a reason')
      end
    end

    def reasons_all_valid?
      reasons.each_with_index do |r, i|
        next unless r.invalid?

        r.errors.each do |attr, message|
          errors.add("reasons[#{i}].#{attr}", message)
        end
      end
    end

    def reasons_attributes=(attributes)
      @reasons ||= []
      attributes.each do |_id, r|
        @reasons.push(RejectionReasonReason.new(r))
      end
    end

    def answered_yes?(question_key)
      label.include?(question_key) && yes?
    end

    def yes?
      y_or_n == 'Y'
    end

    def no?
      !yes?
    end

    alias_method :id, :label
  end
end
