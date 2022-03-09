module ProviderInterface
  class RejectionsWizard
    include Wizard

    validate :valid_rejection_reasons

    class << self
      def rejection_reasons
        @rejection_reasons ||= RejectionReasons.from_config
      end

      delegate  :attribute_names,
                :collection_attribute_names,
                :single_attribute_names,
                :reasons,
                to: :rejection_reasons
    end

    attr_accessor(*attribute_names)

    def initialize_extra(_attrs)
      @checking_answers = true if current_step == 'check'
    end

    def next_step
      'check'
    end

    def valid_rejection_reasons
      rejection_reasons = RejectionReasons.inflate(self)
      errors.merge!(rejection_reasons.errors) unless rejection_reasons.valid?
    end
  end
end
