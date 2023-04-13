class RemoveCanSponsorSkilledWorkerVisaFromProviders < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :providers, :can_sponsor_skilled_worker_visa }
  end
end
