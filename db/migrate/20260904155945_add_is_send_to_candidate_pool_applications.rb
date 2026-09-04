class AddIsSendToCandidatePoolApplications < ActiveRecord::Migration[8.1]
  def change
    add_column :candidate_pool_applications, :is_send, :boolean, default: false
  end
end
