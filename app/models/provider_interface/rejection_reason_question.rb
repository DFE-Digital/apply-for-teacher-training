module ProviderInterface
  class RejectionReasonQuestion
    include ActiveModel::Model

    attr_accessor :label
    attr_accessor :y_or_n
    attr_accessor :reasons
    attr_accessor :answered
    attr_accessor :additional_question

    validates :y_or_n, presence: true
    validate :enough_reasons?, if: -> { y_or_n == 'Y' }
    validate :reasons_all_valid?, if: -> { y_or_n == 'Y' }

    def enough_reasons?
      if reasons.any? && reasons.select(&:value).count.zero?
        errors.add(:y_or_n, 'Please select a reason')
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

    alias_method :id, :label
  end
end
