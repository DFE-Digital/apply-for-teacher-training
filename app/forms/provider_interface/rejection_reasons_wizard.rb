module ProviderInterface
  class RejectionReasonsWizard
    include Wizard

    class << self
      def rejection_reasons
        @rejection_reasons ||= RejectionReasons.from_config
      end

      delegate :attribute_names, :collection_attribute_names, :single_attribute_names, :reasons, to: :rejection_reasons
    end

    attr_accessor(*attribute_names)

    def initialize_extra(_attrs)
      @checking_answers = true if current_step == 'check'
    end

    def next_step
      'check'
    end
  end
end
