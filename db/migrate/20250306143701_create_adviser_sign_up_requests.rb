class CreateAdviserSignUpRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :adviser_sign_up_requests do |t|
      t.references :application_form, null: false, foreign_key: true
      t.references :teaching_subject, null: false, foreign_key: { to_table: :adviser_teaching_subjects }
      t.datetime :sent_to_adviser_at

      t.timestamps
    end
  end
end
