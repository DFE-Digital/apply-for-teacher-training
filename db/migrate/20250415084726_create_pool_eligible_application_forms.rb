class CreatePoolEligibleApplicationForms < ActiveRecord::Migration[8.0]
  def change
    create_table :pool_eligible_application_forms do |t|
      t.string :application_form_id

      t.timestamps
    end
  end
end
