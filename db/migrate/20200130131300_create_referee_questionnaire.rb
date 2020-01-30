class CreateRefereeQuestionnaire < ActiveRecord::Migration[6.0]
  def change
    create_table :referee_questionnaires do |t|
        t.string :experience_rating
        t.string :experience_text
        t.string :guidance_rating
        t.string :guidance_text
        t.boolean :safe_to_work_with_children
        t.string :safe_to_work_with_children_text
        t.boolean :permission_to_contact
        t.string :permission_to_contact_text
        t.timestamps
    end
  end
end
