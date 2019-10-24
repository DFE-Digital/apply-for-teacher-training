class CreateIdOnApplicationChoices < ActiveRecord::Migration[6.0]
  def change
    execute 'ALTER TABLE application_choices DROP CONSTRAINT application_choices_pkey;'
    add_column :application_choices, :id, :primary_key
  end
end
