class AddBreakeableToApplicationWorkHistoryBreak < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference(
      :application_work_history_breaks,
      :breakable,
      polymorphic: true,
      null: true,
      index: { algorithm: :concurrently },
    )
  end
end
