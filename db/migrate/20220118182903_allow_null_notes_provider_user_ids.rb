class AllowNullNotesProviderUserIds < ActiveRecord::Migration[6.1]
  def up
    safety_assured do
      remove_index :notes, name: 'index_notes_on_provider_user_id'
      change_column_null :notes, :provider_user_id, true
    end
  end
end
