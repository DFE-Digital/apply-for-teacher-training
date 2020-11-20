module ProviderInterface
  class ApplicationTimelineComponent < ViewComponent::Base
    attr_reader :application_choice
    validates :application_choice, presence: true

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    Event = Struct.new(:title, :actor, :date, :link_name, :link_path)

    TITLES = {
      'awaiting_provider_decision' => 'Application submitted',
      'withdrawn' => 'Application withdrawn',
      'rejected' => 'Application rejected',
      'offer_withdrawn' => 'Offer withdrawn',
      'offer' => 'Offer made',
      'pending_conditions' => 'Offer accepted',
      'declined' => 'Offer declined',
      'recruited' => 'Recruited',
      'conditions_not_met' => 'Conditions marked not met',
      'offer_deferred' => 'Offer deferred',
    }.freeze

  private

    def status_change_events
      changes = FindStatusChangeAudits.new(application_choice: application_choice).call
      changes = changes.select { |change| TITLES.key?(change.status) }
      changes.map do |change|
        Event.new(
          title_for(change),
          actor_for(change),
          change.changed_at,
          *link_params_for_status(change),
        )
      end
    end

    def note_events
      if application_choice.notes.present?
        application_choice.notes.order('created_at').map do |note|
          Event.new(
            'Note added',
            provider_name(note.provider_user),
            note.created_at,
            'View note',
            provider_interface_application_choice_note_path(application_choice, note),
          )
        end
      else
        []
      end
    end

    def feedback_events
      if application_choice.rejected_by_default
        application_choice.audits.where(action: 'update').where(
          'jsonb_exists(audited_changes, :key)',
          key: :reject_by_default_feedback_sent_at,
        ).order('created_at').map do |feedback_audit|
          Event.new(
            'Feedback sent',
            actor_for(feedback_audit),
            feedback_audit.created_at,
            'View feedback',
            provider_interface_application_choice_path(application_choice),
          )
        end
      else
        []
      end
    end

    def events
      (status_change_events + note_events + feedback_events).sort_by(&:date).reverse
    end

    def title_for(change)
      TITLES[change.status]
    end

    def actor_for(change)
      if change.user.is_a?(Candidate)
        'candidate'
      elsif change.user.is_a?(ProviderUser)
        provider_name(change.user)
      else
        'system'
      end
    end

    def link_params_for_status(change)
      title_for(change).match(/^Application/) ? application_link_params : offer_link_params
    end

    def application_link_params
      ['View application', provider_interface_application_choice_path(application_choice)]
    end

    def offer_link_params
      ['View offer', provider_interface_application_choice_offer_path(application_choice)]
    end

    def provider_name(provider_user)
      # TODO: Work out how to display the provider name (it's ambiguous)
      provider_user.full_name
    end
  end
end
