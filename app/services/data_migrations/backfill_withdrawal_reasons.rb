module DataMigrations
  class BackfillWithdrawalReasons
    TIMESTAMP = 20241023160952
    MANUAL_RUN = true

    WITHDRAWAL_REASONS_MAPPING = {
      'application_unsuccessful' => 'asked_to_withdraw',
      'change_of_course_option' => 'applying_to_different_course_same_provider',
      'change_of_training_provider' => 'applying_to_different_provider',
      'circumstances_changed' => 'no_longer_want_to_train_to_teach',
      'costs' => 'concerns_about_cost',
      'course_location' => 'training_location_too_far_away',
      'course_unavailable' => 'course_not_available_anymore',
      'deferred' => 'applying_to_teacher_training_next_year',
      # Yes, flexible is spelled incorrectly
      'flexibile_itt_study_intensity' => 'concerns_about_time_to_train',
      'flexible_itt_course_date' => 'wait_to_start_course_too_long',
      'flexible_itt_disabilities' => 'concerns_about_training_with_disability_or_health_condition',
      'provider_behaviour' => 'training_provider_has_not_responded',
    }.freeze

    def change
      choices.in_batches(of: 5_000) do |choices_batch|
        choices_attributes = choices_batch.as_json.map do |attributes|
          { **attributes, structured_withdrawal_reasons: mapped_reasons(attributes['structured_withdrawal_reasons']) }
        end
        ApplicationChoice.upsert_all(
          choices_attributes,
          record_timestamps: false,
          returning: false,
          update_only: [:structured_withdrawal_reasons],
        )
      end
    end

  private

    def choices
      ApplicationChoice.where.not(structured_withdrawal_reasons: [])
    end

    def mapped_reasons(original_reasons)
      Array.wrap(original_reasons).map do |original_reason|
        WITHDRAWAL_REASONS_MAPPING.fetch(original_reason, nil)
      end.compact
    end
  end
end
