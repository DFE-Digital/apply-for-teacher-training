class RenameTitleToSubjectInNotes < ActiveRecord::Migration[6.0]
  def change
    change_table :notes do |t|
      t.rename :title, :subject
    end
  end
end
