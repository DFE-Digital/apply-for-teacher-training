module ProviderInterface
  class SortApplicationChoices
    RBD_FEEDBACK_LAUNCH_TIMESTAMP = '\'2020-11-17T00:00:00+00:00\'::TIMESTAMPTZ'.freeze

    def self.call(application_choices:)
      for_task_view(application_choices).order(sort_order)
    end

    def self.for_task_view(application_choices)
      application_choices.from <<~WITH_TASK_VIEW_GROUP.squish
        (
          SELECT a.*, c.recruitment_cycle_year,
            CASE
              WHEN #{deferred_offers_pending_reconfirmation} THEN 1
              WHEN #{about_to_be_rejected_automatically} THEN 2
              WHEN #{give_feedback_for_rbd} THEN 3
              WHEN #{awaiting_provider_decision_non_urgent} THEN 4
              WHEN #{interviewing_non_urgent} THEN 5
              WHEN #{pending_conditions_previous_cycle} THEN 6
              WHEN #{waiting_on_candidate} THEN 7
              WHEN #{pending_conditions_current_cycle} THEN 8
              WHEN #{successful_candidates} THEN 9
              WHEN #{deferred_offers_current_cycle} THEN 10
              ELSE 999
            END AS task_view_group,
            #{pg_days_left_to_respond} AS pg_days_left_to_respond

            FROM application_choices a
            LEFT JOIN course_options option
              ON option.id = a.current_course_option_id
            LEFT JOIN courses c
              ON c.id = option.course_id
        ) AS application_choices
      WITH_TASK_VIEW_GROUP
    end

    def self.deferred_offers_pending_reconfirmation
      <<~DEFERRED_OFFERS_PENDING_RECONFIRMATION.squish
        (
          status = 'offer_deferred'
            AND c.recruitment_cycle_year = #{RecruitmentCycle.previous_year}
        )
      DEFERRED_OFFERS_PENDING_RECONFIRMATION
    end

    def self.pending_conditions_previous_cycle
      <<~PREVIOUS_CYCLE_PENDING_CONDITIONS.squish
        (
          status = 'pending_conditions'
            AND c.recruitment_cycle_year = #{RecruitmentCycle.previous_year}
        )
      PREVIOUS_CYCLE_PENDING_CONDITIONS
    end

    def self.about_to_be_rejected_automatically
      <<~DEADLINE_APPROACHING.squish
        (
          (status = 'awaiting_provider_decision' OR status = 'interviewing')
            AND c.recruitment_cycle_year = #{RecruitmentCycle.current_year}
            AND (
              DATE(reject_by_default_at)
              BETWEEN
                DATE('#{Time.zone.now.iso8601}'::TIMESTAMPTZ)
              AND
                DATE('#{5.business_days.after(Time.zone.now).iso8601}'::TIMESTAMPTZ)
            )
        )
      DEADLINE_APPROACHING
    end

    def self.give_feedback_for_rbd
      <<~GIVE_FEEDBACK_FOR_RBD.squish
        (
          status = 'rejected'
            AND rejected_by_default
            AND rejection_reason IS NULL
            AND structured_rejection_reasons IS NULL
            AND rejected_at >= #{RBD_FEEDBACK_LAUNCH_TIMESTAMP}
        )
      GIVE_FEEDBACK_FOR_RBD
    end

    def self.awaiting_provider_decision_non_urgent
      <<~AWAITING_PROVIDER_DECISION.squish
        (
          status = 'awaiting_provider_decision'
            AND (
              DATE(reject_by_default_at) >= DATE('#{Time.zone.now.iso8601}'::TIMESTAMPTZ)
            )
        )
      AWAITING_PROVIDER_DECISION
    end

    def self.interviewing_non_urgent
      <<~INTERVIEWING_NOT_URGENT.squish
        (
          status = 'interviewing'
            AND (
              DATE(reject_by_default_at) >= DATE('#{Time.zone.now.iso8601}'::TIMESTAMPTZ)
            )
        )
      INTERVIEWING_NOT_URGENT
    end

    def self.waiting_on_candidate
      <<~WAITING_ON_CANDIDATE.squish
        (
          status = 'offer'
            AND c.recruitment_cycle_year = #{RecruitmentCycle.current_year}
        )
      WAITING_ON_CANDIDATE
    end

    def self.pending_conditions_current_cycle
      <<~CURRENT_CYCLE_PENDING_CONDITIONS.squish
        (
          status = 'pending_conditions'
            AND c.recruitment_cycle_year = #{RecruitmentCycle.current_year}
        )
      CURRENT_CYCLE_PENDING_CONDITIONS
    end

    def self.successful_candidates
      <<~SUCCESSFUL_CANDIDATES.squish
        (
          status = 'recruited'
            AND c.recruitment_cycle_year = #{RecruitmentCycle.current_year}
        )
      SUCCESSFUL_CANDIDATES
    end

    def self.deferred_offers_current_cycle
      <<~DEFERRED_OFFERS_CURRENT_CYCLE.squish
        (
          status = 'offer_deferred'
            AND c.recruitment_cycle_year = #{RecruitmentCycle.current_year}
        )
      DEFERRED_OFFERS_CURRENT_CYCLE
    end

    def self.pg_days_left_to_respond
      <<~PG_DAYS_LEFT_TO_RESPOND.squish
        CASE
          WHEN status = 'awaiting_provider_decision'
          AND (DATE(reject_by_default_at) >= DATE('#{Time.zone.now.iso8601}'))
          THEN (DATE(reject_by_default_at) - DATE('#{Time.zone.now.iso8601}'))
          ELSE NULL END
      PG_DAYS_LEFT_TO_RESPOND
    end

    def self.sort_order
      <<~ORDER_BY.squish
        task_view_group,
        pg_days_left_to_respond,
        application_choices.updated_at DESC
      ORDER_BY
    end
  end
end
