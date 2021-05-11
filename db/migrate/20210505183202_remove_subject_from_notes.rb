class RemoveSubjectFromNotes < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :notes, :subject, :text }
  end
end
