class AddApplicationFormToPoolInvite < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_reference :pool_invites, :application_form, index: { algorithm: :concurrently }
  end
end
