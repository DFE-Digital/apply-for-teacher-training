class AddApplicationFeedbackTable < ActiveRecord::Migration[6.0]
  def change
    create_table :application_feedback do |t|
      t.string :section, null: false
      t.string :path, null: false
      t.string :page_title, null: false
      t.boolean :issues, null: false, default: false
      t.boolean :does_not_understand_section, null: false, default: false
      t.boolean :need_more_information, null: false, default: false
      t.boolean :answer_does_not_fit_format, null: false, default: false
      t.string :other_feedback
      t.boolean :consent_to_be_contacted, null: false, default: false
      t.references :application_form, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end
  end
end
