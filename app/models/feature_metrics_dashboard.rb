class FeatureMetricsDashboard < ApplicationRecord
  MISSING_VALUE = 'n/a'.freeze

  def write_metric(key, value)
    self.metrics = (metrics || {}).merge(key.to_s => value)
  end

  def read_metric(key)
    metrics[key.to_s] || MISSING_VALUE
  end

  def load_updated_metrics
    load_avg_time_to_get_references
    load_pct_references_completed_within_30_days
    load_avg_time_to_complete_work_history
    load_avg_sign_ins_before_submitting
    load_avg_sign_ins_before_offer
    load_avg_sign_ins_before_recruitment
    load_num_rejections_due_to_qualifications
    load_apply_again_success_rate
    load_apply_again_change_rate
    load_apply_again_application_rate
    load_carry_over_counts
    load_qualifications
    load_satisfaction_survey_response_rate
    load_satisfaction_survey_positive_feedback_rate
    load_equality_and_diversity_response_rate
  end

  def last_updated_at
    updated_at.to_s(:govuk_date_and_time)
  end

  def next_update_exepected_at
    (updated_at + 1.hour).to_s(:govuk_date_and_time)
  end

private

  def reference_statistics
    ReferenceFeatureMetrics.new
  end

  def work_history_statistics
    WorkHistoryFeatureMetrics.new
  end

  def magic_link_statistics
    MagicLinkFeatureMetrics.new
  end

  def reasons_for_rejection_statistics
    ReasonsForRejectionFeatureMetrics.new
  end

  def apply_again_statistics
    ApplyAgainFeatureMetrics.new
  end

  def carry_over_statistics
    CarryOverFeatureMetrics.new
  end

  def qualifications_statistics
    QualificationsFeatureMetrics.new
  end

  def satisfaction_survey_statistics
    SatisfactionSurveyFeatureMetrics.new
  end

  def equality_and_diversity_statistics
    EqualityAndDiversityFeatureMetrics.new
  end

  def load_avg_time_to_get_references
    write_metric(
      :avg_time_to_get_references,
      reference_statistics.average_time_to_get_references(CycleTimetable.apply_reopens.beginning_of_day),
    )
    write_metric(
      :avg_time_to_get_references_this_month,
      reference_statistics.average_time_to_get_references(Time.zone.now.beginning_of_month),
    )
    write_metric(
      :avg_time_to_get_references_last_month,
      reference_statistics.average_time_to_get_references(
        Time.zone.now.beginning_of_month - 1.month, Time.zone.now.beginning_of_month
      ),
    )
  end

  def load_pct_references_completed_within_30_days
    write_metric(
      :pct_references_completed_within_30_days,
      reference_statistics.percentage_references_within(
        30, CycleTimetable.apply_reopens.beginning_of_day
      ),
    )
    write_metric(
      :pct_references_completed_within_30_days_this_month,
      reference_statistics.percentage_references_within(
        30, Time.zone.now.beginning_of_month
      ),
    )
    write_metric(
      :pct_references_completed_within_30_days_last_month,
      reference_statistics.percentage_references_within(
        30, Time.zone.now.beginning_of_month - 1.month, Time.zone.now.beginning_of_month
      ),
    )
  end

  def load_avg_time_to_complete_work_history
    write_metric(
      :avg_time_to_complete_work_history,
      work_history_statistics.average_time_to_complete(CycleTimetable.apply_reopens.beginning_of_day),
    )
    write_metric(
      :avg_time_to_complete_work_history_this_month,
      work_history_statistics.average_time_to_complete(Time.zone.now.beginning_of_month),
    )
    write_metric(
      :avg_time_to_complete_work_history_last_month,
      work_history_statistics.average_time_to_complete(
        Time.zone.now.beginning_of_month - 1.month, Time.zone.now.beginning_of_month
      ),
    )
  end

  def load_avg_sign_ins_before_submitting
    write_metric(
      :avg_sign_ins_before_submitting,
      magic_link_statistics.average_magic_link_requests_upto(
        :created_at, CycleTimetable.apply_reopens.beginning_of_day
      ),
    )
    write_metric(
      :avg_sign_ins_before_submitting_this_month,
      magic_link_statistics.average_magic_link_requests_upto(
        :created_at, Time.zone.now.beginning_of_month
      ),
    )
    write_metric(
      :avg_sign_ins_before_submitting_last_month,
      magic_link_statistics.average_magic_link_requests_upto(
        :created_at, Time.zone.now.beginning_of_month - 1.month, Time.zone.now.beginning_of_month
      ),
    )
  end

  def load_avg_sign_ins_before_offer
    write_metric(
      :avg_sign_ins_before_offer,
      magic_link_statistics.average_magic_link_requests_upto(
        :offered_at, CycleTimetable.apply_reopens.beginning_of_day
      ),
    )
    write_metric(
      :avg_sign_ins_before_offer_this_month,
      magic_link_statistics.average_magic_link_requests_upto(
        :offered_at, Time.zone.now.beginning_of_month
      ),
    )
    write_metric(
      :avg_sign_ins_before_offer_last_month,
      magic_link_statistics.average_magic_link_requests_upto(
        :offered_at, Time.zone.now.beginning_of_month - 1.month, Time.zone.now.beginning_of_month
      ),
    )
  end

  def load_avg_sign_ins_before_recruitment
    write_metric(
      :avg_sign_ins_before_recruitment,
      magic_link_statistics.average_magic_link_requests_upto(
        :recruited_at, CycleTimetable.apply_reopens.beginning_of_day
      ),
    )
    write_metric(
      :avg_sign_ins_before_recruitment_this_month,
      magic_link_statistics.average_magic_link_requests_upto(
        :recruited_at, Time.zone.now.beginning_of_month
      ),
    )
    write_metric(
      :avg_sign_ins_before_recruitment_last_month,
      magic_link_statistics.average_magic_link_requests_upto(
        :recruited_at, Time.zone.now.beginning_of_month - 1.month, Time.zone.now.beginning_of_month
      ),
    )
  end

  def load_num_rejections_due_to_qualifications
    write_metric(
      :num_rejections_due_to_qualifications,
      reasons_for_rejection_statistics.rejections_due_to(
        :qualifications_y_n, CycleTimetable.apply_reopens.beginning_of_day
      ),
    )
    write_metric(
      :num_rejections_due_to_qualifications_this_month,
      reasons_for_rejection_statistics.rejections_due_to(
        :qualifications_y_n, Time.zone.now.beginning_of_month
      ),
    )
    write_metric(
      :num_rejections_due_to_qualifications_last_month,
      reasons_for_rejection_statistics.rejections_due_to(
        :qualifications_y_n, Time.zone.now.beginning_of_month - 1.month, Time.zone.now.beginning_of_month
      ),
    )
  end

  def load_apply_again_success_rate
    write_metric(
      :apply_again_success_rate,
      apply_again_statistics.formatted_success_rate(
        CycleTimetable.apply_reopens.beginning_of_day,
      ),
    )
    write_metric(
      :apply_again_success_rate_this_month,
      apply_again_statistics.formatted_success_rate(
        Time.zone.now.beginning_of_month,
      ),
    )
    write_metric(
      :apply_again_success_rate_upto_this_month,
      apply_again_statistics.formatted_success_rate(
        CycleTimetable.apply_reopens.beginning_of_day,
        Time.zone.now.beginning_of_month,
      ),
    )
  end

  def load_apply_again_change_rate
    write_metric(
      :apply_again_change_rate,
      apply_again_statistics.formatted_change_rate(
        CycleTimetable.apply_reopens.beginning_of_day,
      ),
    )
    write_metric(
      :apply_again_change_rate_this_month,
      apply_again_statistics.formatted_change_rate(
        Time.zone.now.beginning_of_month,
      ),
    )
    write_metric(
      :apply_again_change_rate_last_month,
      apply_again_statistics.formatted_change_rate(
        Time.zone.now.beginning_of_month - 1.month,
        Time.zone.now.beginning_of_month,
      ),
    )
  end

  def load_apply_again_application_rate
    write_metric(
      :apply_again_application_rate,
      apply_again_statistics.formatted_application_rate(
        CycleTimetable.apply_reopens.beginning_of_day,
      ),
    )
    write_metric(
      :apply_again_application_rate_this_month,
      apply_again_statistics.formatted_application_rate(
        Time.zone.now.beginning_of_month,
      ),
    )
    write_metric(
      :apply_again_application_rate_upto_this_month,
      apply_again_statistics.formatted_application_rate(
        CycleTimetable.apply_reopens.beginning_of_day,
        Time.zone.now.beginning_of_month,
      ),
    )
  end

  def load_carry_over_counts
    write_metric(
      :carry_over_count,
      carry_over_statistics.carry_over_count(
        CycleTimetable.apply_reopens.beginning_of_day,
      ),
    )
    write_metric(
      :carry_over_count_this_month,
      carry_over_statistics.carry_over_count(
        Time.zone.now.beginning_of_month,
      ),
    )
    write_metric(
      :carry_over_count_last_month,
      carry_over_statistics.carry_over_count(
        CycleTimetable.apply_reopens.beginning_of_day,
        Time.zone.now.beginning_of_month,
      ),
    )
  end

  def load_qualifications
    write_metric(
      :pct_applications_with_one_a_level,
      qualifications_statistics.formatted_a_level_percentage(
        1,
        CycleTimetable.apply_reopens.beginning_of_day,
      ),
    )
    write_metric(
      :pct_applications_with_one_a_level_this_month,
      qualifications_statistics.formatted_a_level_percentage(
        1,
        Time.zone.now.beginning_of_month,
      ),
    )
    write_metric(
      :pct_applications_with_one_a_level_last_month,
      qualifications_statistics.formatted_a_level_percentage(
        1,
        Time.zone.now.beginning_of_month - 1.month,
        Time.zone.now.beginning_of_month,
      ),
    )
    write_metric(
      :pct_applications_with_three_a_levels,
      qualifications_statistics.formatted_a_level_percentage(
        3,
        CycleTimetable.apply_reopens.beginning_of_day,
      ),
    )
    write_metric(
      :pct_applications_with_three_a_levels_this_month,
      qualifications_statistics.formatted_a_level_percentage(
        3,
        Time.zone.now.beginning_of_month,
      ),
    )
    write_metric(
      :pct_applications_with_three_a_levels_last_month,
      qualifications_statistics.formatted_a_level_percentage(
        3,
        Time.zone.now.beginning_of_month - 1.month,
        Time.zone.now.beginning_of_month,
      ),
    )
  end

  def load_satisfaction_survey_response_rate
    write_metric(
      :satisfaction_survey_response_rate,
      satisfaction_survey_statistics.formatted_response_rate(
        CycleTimetable.apply_reopens.beginning_of_day,
      ),
    )
    write_metric(
      :satisfaction_survey_response_rate_this_month,
      satisfaction_survey_statistics.formatted_response_rate(
        Time.zone.now.beginning_of_month,
      ),
    )
    write_metric(
      :satisfaction_survey_response_rate_last_month,
      satisfaction_survey_statistics.formatted_response_rate(
        Time.zone.now.beginning_of_month - 1.month,
        Time.zone.now.beginning_of_month,
      ),
    )
  end

  def load_satisfaction_survey_positive_feedback_rate
    write_metric(
      :satisfaction_survey_positive_feedback_rate,
      satisfaction_survey_statistics.formatted_positive_feedback_rate(
        CycleTimetable.apply_reopens.beginning_of_day,
      ),
    )
    write_metric(
      :satisfaction_survey_positive_feedback_rate_this_month,
      satisfaction_survey_statistics.formatted_positive_feedback_rate(
        Time.zone.now.beginning_of_month,
      ),
    )
    write_metric(
      :satisfaction_survey_positive_feedback_rate_last_month,
      satisfaction_survey_statistics.formatted_positive_feedback_rate(
        Time.zone.now.beginning_of_month - 1.month,
        Time.zone.now.beginning_of_month,
      ),
    )
  end

  def load_equality_and_diversity_response_rate
    write_metric(
      :equality_and_diversity_response_rate,
      equality_and_diversity_statistics.formatted_response_rate(
        CycleTimetable.apply_reopens.beginning_of_day,
      ),
    )
    write_metric(
      :equality_and_diversity_response_rate_this_month,
      equality_and_diversity_statistics.formatted_response_rate(
        Time.zone.now.beginning_of_month,
      ),
    )
    write_metric(
      :equality_and_diversity_response_rate_last_month,
      equality_and_diversity_statistics.formatted_response_rate(
        Time.zone.now.beginning_of_month - 1.month,
        Time.zone.now.beginning_of_month,
      ),
    )
  end
end
