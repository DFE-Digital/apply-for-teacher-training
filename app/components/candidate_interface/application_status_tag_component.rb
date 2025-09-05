module CandidateInterface
  class ApplicationStatusTagComponent < ApplicationComponent
    delegate :status, to: :application_choice

    def initialize(application_choice:, display_info_text: true)
      @application_choice = application_choice
      @display_info_text = display_info_text
      @supplementary_statuses = application_choice.respond_to?(:supplementary_statuses) ? application_choice.supplementary_statuses : []
    end

    def text
      t("candidate_application_states.#{application_choice.status}")
    end

    def colour
      case application_choice.status
      when 'unsubmitted'
        'blue'
      when 'awaiting_provider_decision'
        'purple'
      when 'conditions_not_met', 'declined', 'cancelled'
        'red'
      when 'offer', 'pending_conditions', 'recruited'
        'green'
      when 'offer_withdrawn'
        'pink'
      when 'offer_deferred', 'interviewing', 'inactive'
        'yellow'
      when 'withdrawn', 'application_not_sent', 'rejected'
        'orange'
      else
        raise "You need to define a colour for the #{status} state"
      end
    end

    def supplementary_tags
      @supplementary_statuses.each do |supplementary_status|
        yield supplementary_tag_text(supplementary_status), supplementary_tag_colour(supplementary_status)
      end
    end

  private

    def supplementary_tag_text(supplementary_status)
      I18n.t!("supplementary_application_states.#{supplementary_status}.name")
    end

    def supplementary_tag_colour(supplementary_status)
      case supplementary_status.to_s
      when 'ske_pending_conditions'
        'blue'
      else
        raise "You need to define a colour for the #{supplementary_status} supplementary state"
      end
    end

    attr_reader :application_choice
  end
end
