module CandidateInterface
  class AdditionalRefereesStartComponent < ActionView::Component::Base
    include ViewHelper

    validates :application_form, presence: true

    def initialize(application_form:)
      @application_form = application_form
    end

  private

    def reference_status
      @reference_status ||= ReferenceStatus.new(application_form)
    end

    def title
      if reference_status.number_of_references_that_currently_need_replacing == 1
        'You need to add a new referee'
      else
        'You need to add 2 new referees'
      end
    end

    def reason_for_replacement(referee)
      case referee.feedback_status
      when 'email_bounced'
        "Our email requesting a reference didn’t reach #{referee.name}"
      when 'feedback_refused'
        "#{referee.name} said they won’t give a reference"
      else
        "#{referee.name} did not respond to our request"
      end
    end

    def references_that_need_replacement
      @reference_status.references_that_needed_to_be_replaced
    end

    attr_reader :application_form
  end
end
