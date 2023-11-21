class ChaserSent < ApplicationRecord
  belongs_to :chased, polymorphic: true

  enum chaser_type: {
    reference_request: 'reference_request',
    referee_reference_request: 'referee_reference_request',
    candidate_reference_request: 'candidate_reference_request',
    reference_replacement: 'reference_replacement',
    follow_up_missing_references: 'follow_up_missing_references',
    candidate_follow_up_missing_references: 'candidate_follow_up_missing_references',
    referee_follow_up_missing_references: 'referee_follow_up_missing_references',
    reminder_reference_nudge: 'reminder_reference_nudge',
    candidate_decision_request: 'candidate_decision_request',
    course_unavailable_notification: 'course_unavailable_notification',
    course_unavailable_slack_notification: 'course_unavailable_slack_notification',
    eoc_deadline_reminder: 'eoc_deadline_reminder',
    find_has_opened: 'find_has_opened',
    new_cycle_has_started: 'new_cycle_has_started',
    set_up_organisation_permissions: 'set_up_organisation_permissions',
    apply_service_is_now_open: 'apply_service_is_now_open',
    find_service_is_now_open: 'find_service_is_now_open',
    apply_service_open_organisation_notification: 'apply_service_open_organisation_notification',
    find_service_open_organisation_notification: 'find_service_open_organisation_notification',
    apply_to_another_course_after_30_working_days: 'apply_to_another_course_after_30_working_days',
    apply_to_multiple_courses_after_30_working_days: 'apply_to_multiple_courses_after_30_working_days',
  }
end
