class DropOpenOnApplyColumnsFromCourse < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      change_table :courses do |t|
        t.remove :open_on_apply
        t.remove :opened_on_apply_at
      end
    end
  end

  def down
    change_table :courses do |t|
      t.column :open_on_apply, :boolean, default: false, null: false
      t.column :opened_on_apply_at, :datetime
      t.index %i[exposed_in_find open_on_apply], algorithm: :concurrently
    end
  end
end
