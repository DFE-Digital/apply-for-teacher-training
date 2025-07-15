class AddApplicationChoiceIdToInvite < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_reference :pool_invites, :application_choice, null: true, index: { algorithm: :concurrently }
  end
end
