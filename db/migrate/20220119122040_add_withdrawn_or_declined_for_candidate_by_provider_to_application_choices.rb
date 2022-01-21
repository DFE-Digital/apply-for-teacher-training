class AddWithdrawnOrDeclinedForCandidateByProviderToApplicationChoices < ActiveRecord::Migration[6.1]
  def change
    add_column :application_choices, :withdrawn_or_declined_for_candidate_by_provider, :boolean
  end
end
