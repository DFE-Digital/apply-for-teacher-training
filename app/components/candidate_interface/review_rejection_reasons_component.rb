module CandidateInterface
  class ReviewRejectionReasonsComponent < ApplicationComponent
    include ViewHelper

    attr_reader :rejection_reasons

    def initialize(rejection_reasons)
      @rejection_reasons = rejection_reasons
    end

    def hide_other_label?
      rejection_reasons.one? && rejection_reasons.first.label == 'Other'
    end
  end
end
