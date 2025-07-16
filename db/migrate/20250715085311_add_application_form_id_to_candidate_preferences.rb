class AddApplicationFormIdToCandidatePreferences < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_reference :candidate_preferences, :application_form, null: true, index: { algorithm: :concurrently }
  end
end
