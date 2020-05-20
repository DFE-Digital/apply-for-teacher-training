class BackfillSentToProviderAt < ActiveRecord::Migration[6.0]
  def up
    ApplicationChoice.all.each do |application_choice|
      state_change = application_choice.audits.find do |audit|
        audit.audited_changes['status'] == %w[application_complete awaiting_provider_decision]
      end

      next unless state_change

      application_choice.update!(
        sent_to_provider_at: state_change.created_at,
        audit_comment: 'Backfill of `sent_to_provider_at`',
      )
      Rails.logger.info(
        "Application form #{application_choice.application_form.id} was sent to the provider at #{state_change.created_at}",
      )
    end
  end

  def down
    # Nothing to do
  end
end
