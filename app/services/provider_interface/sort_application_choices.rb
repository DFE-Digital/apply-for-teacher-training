module ProviderInterface
  class SortApplicationChoices
    def self.call(application_choices:)
      for_task_view(application_choices).order(sort_order)
    end

    def self.for_task_view(application_choices)
      application_choices.from <<~WITH_TASK_VIEW_GROUP.squish
        (
          SELECT a.*, c.recruitment_cycle_year,
            CASE
              WHEN #{deferred_offers_pending_reconfirmation} THEN 1
              WHEN #{previous_cycle_pending_conditions} THEN 2
              WHEN #{about_to_be_rejected_automatically} THEN 4
              WHEN #{awaiting_provider_decision} THEN 5
              WHEN #{waiting_on_candidate} THEN 6
              ELSE 999
            END AS task_view_group,
            #{pg_days_left_to_respond} AS pg_days_left_to_respond

            FROM application_choices a
            LEFT JOIN courses c ON c.id = a.course_option_id
        ) AS application_choices
      WITH_TASK_VIEW_GROUP
    end

    def self.deferred_offers_pending_reconfirmation
      # TODO: this query depends on deferrals implementation
      <<~DEFERRED_OFFERS_PENDING_RECONFIRMATION.squish
        (
          status='deferred'
            AND c.recruitment_cycle_year = #{RecruitmentCycle.current_year}
        )
      DEFERRED_OFFERS_PENDING_RECONFIRMATION
    end

    def self.previous_cycle_pending_conditions
      <<~PREVIOUS_CYCLE_PENDING_CONDITIONS.squish
        (
          status='pending_conditions'
            AND c.recruitment_cycle_year = #{RecruitmentCycle.previous_year}
        )
      PREVIOUS_CYCLE_PENDING_CONDITIONS
    end

    def self.about_to_be_rejected_automatically
      <<~AWAITING_PROVIDER_DECISION.squish
        (
          status='awaiting_provider_decision'
            AND c.recruitment_cycle_year = #{RecruitmentCycle.current_year}
            AND (
              DATE(reject_by_default_at)
              BETWEEN
                DATE('#{Time.zone.now.iso8601}')
              AND
                DATE('#{3.business_days.after(Time.zone.now).iso8601}')
            )
        )
      AWAITING_PROVIDER_DECISION
    end

    def self.awaiting_provider_decision
      <<~AWAITING_PROVIDER_DECISION.squish
        (
          status='awaiting_provider_decision'
            AND (
              DATE(reject_by_default_at) >
                DATE('#{3.business_days.after(Time.zone.now).iso8601}')
            )
        )
      AWAITING_PROVIDER_DECISION
    end

    def self.waiting_on_candidate
      <<~WAITING_ON_CANDIDATE.squish
        (
          status='offer'
            AND c.recruitment_cycle_year = #{RecruitmentCycle.current_year}
        )
      WAITING_ON_CANDIDATE
    end

    def self.pg_days_left_to_respond
      <<~PG_DAYS_LEFT_TO_RESPOND.squish
        CASE
          WHEN (DATE(reject_by_default_at) > DATE('#{Time.zone.now.iso8601}'))
          THEN (DATE(reject_by_default_at) - DATE('#{Time.zone.now.iso8601}'))
          ELSE NULL END
      PG_DAYS_LEFT_TO_RESPOND
    end

    def self.sort_order
      <<~ORDER_BY.squish
        task_view_group,
        status,
        pg_days_left_to_respond,
        application_choices.updated_at
      ORDER_BY
    end
  end
end
