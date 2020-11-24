class AddUniqueIndexToApplicationChoices < ActiveRecord::Migration[6.0]
  def change
    add_index :application_choices,
              %i[application_form_id course_option_id],
              unique: true, name: 'index_course_option_to_application_form_id'
  end
end
