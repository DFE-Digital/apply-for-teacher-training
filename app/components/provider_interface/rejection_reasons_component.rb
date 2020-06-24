module ProviderInterface
  class RejectionReasonsComponent < ViewComponent::Base
    def initialize(rejection_reasons: nil)
      @rejection_reasons = rejection_reasons
    end

    def renderable_reasons
      result = @rejection_reasons.reject do |r|
        r.no? || r.label.include?('future_applications')
      end

      if result.last.label.include?('alternative_rejection_reason')
        result.unshift(result.pop)
      end

      result
    end

    def answered_yes_to_question?(question_key)
      @rejection_reasons.find { |rr| rr.label.include?(question_key) }&.yes?
    end
  end
end
