class BackfillNewApplicationReferenceDatetimeColumns < ActiveRecord::Migration[6.0]
  def up
    ApplicationReference
    .all
    .each do |reference|
      feedback_provided_at = reference.audits.where("audited_changes#>>'{feedback_status, 1}' = 'feedback_provided'").last&.created_at
      feedback_refused_at = reference.audits.where("audited_changes#>>'{feedback_status, 1}' = 'feedback_refused'").last&.created_at
      cancelled_at = reference.audits.where("audited_changes#>>'{feedback_status, 1}' = 'cancelled'").last&.created_at
      cancelled_at_eoc_at = reference.audits.where("audited_changes#>>'{feedback_status, 1}' = 'cancelled_at_end_of_cycle'").last&.created_at
      email_bounced_at = reference.audits.where("audited_changes#>>'{feedback_status, 1}' = 'email_bounced'").last&.created_at

      reference.update!(
        feedback_provided_at: feedback_provided_at,
        feedback_refused_at: feedback_refused_at,
        cancelled_at: cancelled_at,
        cancelled_at_end_of_cycle_at: cancelled_at_eoc_at,
        email_bounced_at: email_bounced_at,
        audit_comment: 'Backfilled after adding new datetime columns https://github.com/DFE-Digital/apply-for-teacher-training/pull/3901',
      )
    end
  end

  def down
    ApplicationReference
    .all
    .each do |reference|
      reference.update!(
        feedback_provided_at: nil,
        feedback_refused_at: nil,
        cancelled_at: nil,
        cancelled_at_end_of_cycle_at: nil,
        email_bounced_at: nil,
      )
    end
  end
end
