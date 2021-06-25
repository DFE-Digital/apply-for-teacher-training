class ChaserSent < ApplicationRecord
  belongs_to :chased, polymorphic: true

  enum chaser_type: {
    reference_request: 'reference_request',
    reference_replacement: 'reference_replacement',
    follow_up_missing_references: 'follow_up_missing_references',
    provider_decision_request: 'provider_decision_request',
    candidate_decision_request: 'candidate_decision_request',
    course_unavailable_notification: 'course_unavailable_notification',
    course_unavailable_slack_notification: 'course_unavailable_slack_notification',
    eoc_deadline_reminder: 'eoc_deadline_reminder',
  }
end
