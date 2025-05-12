class CreatePoolEligibleApplicationForms < ActiveRecord::Migration[8.0]
  def change
    create_table :pool_eligible_application_forms do |t|
      t.references :application_form, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
