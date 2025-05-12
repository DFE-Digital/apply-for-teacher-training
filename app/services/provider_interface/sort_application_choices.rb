module ProviderInterface
  class SortApplicationChoices
    RBD_FEEDBACK_LAUNCH_TIMESTAMP = '\'2020-11-17T00:00:00+00:00\'::TIMESTAMPTZ'.freeze

    extend ApplicationHelper

    def self.call(application_choices:)
      for_task_view(application_choices).order(sort_order)
    end

    def self.for_task_view(application_choices)
      # Explicitly list the columns so that the 'ignored_columns' on the model are not included in the raw SQL.
      columns = ApplicationChoice.new.attribute_names.map { |key| "application_choices.#{key}" }.join(', ')

      application_choices.select(
        "#{columns},
        CASE
          WHEN #{inactive} THEN 1
          WHEN #{awaiting_provider_decision} THEN 2
          WHEN #{deferred_offers_pending_reconfirmation} THEN 3
          WHEN #{interviewing} THEN 4
          WHEN #{pending_conditions_previous_cycle} THEN 5
          WHEN #{waiting_on_candidate} THEN 6
          WHEN #{pending_conditions_current_cycle} THEN 7
          WHEN #{successful_candidates} THEN 8
          WHEN #{deferred_offers_current_cycle} THEN 9
          ELSE 999
        END AS task_view_group",
      )
    end

    def self.deferred_offers_pending_reconfirmation
      <<~DEFERRED_OFFERS_PENDING_RECONFIRMATION.squish
        (
          status = 'offer_deferred'
            AND current_recruitment_cycle_year = #{previous_year}
        )
      DEFERRED_OFFERS_PENDING_RECONFIRMATION
    end

    def self.pending_conditions_previous_cycle
      <<~PREVIOUS_CYCLE_PENDING_CONDITIONS.squish
        (
          status = 'pending_conditions'
            AND current_recruitment_cycle_year = #{previous_year}
        )
      PREVIOUS_CYCLE_PENDING_CONDITIONS
    end

    def self.awaiting_provider_decision
      <<~AWAITING_PROVIDER_DECISION.squish
        (status = 'awaiting_provider_decision')
      AWAITING_PROVIDER_DECISION
    end

    def self.inactive
      <<~INACTIVE.squish
        (status = 'inactive')
      INACTIVE
    end

    def self.interviewing
      <<~INTERVIEWING.squish
        (status = 'interviewing')
      INTERVIEWING
    end

    def self.waiting_on_candidate
      <<~WAITING_ON_CANDIDATE.squish
        (
          status = 'offer'
            AND current_recruitment_cycle_year = #{current_year}
        )
      WAITING_ON_CANDIDATE
    end

    def self.pending_conditions_current_cycle
      <<~CURRENT_CYCLE_PENDING_CONDITIONS.squish
        (
          status = 'pending_conditions'
            AND current_recruitment_cycle_year = #{current_year}
        )
      CURRENT_CYCLE_PENDING_CONDITIONS
    end

    def self.successful_candidates
      <<~SUCCESSFUL_CANDIDATES.squish
        (
          status = 'recruited'
            AND current_recruitment_cycle_year = #{current_year}
        )
      SUCCESSFUL_CANDIDATES
    end

    def self.deferred_offers_current_cycle
      <<~DEFERRED_OFFERS_CURRENT_CYCLE.squish
        (
          status = 'offer_deferred'
            AND current_recruitment_cycle_year = #{current_year}
        )
      DEFERRED_OFFERS_CURRENT_CYCLE
    end

    def self.sort_order
      <<~ORDER_BY.squish
        task_view_group,
        application_choices.updated_at DESC
      ORDER_BY
    end

    def self.current_year
      @current_year ||= RecruitmentCycleTimetable.current_year
    end

    def self.previous_year
      @previous_year ||= RecruitmentCycleTimetable.previous_year
    end
  end
end
