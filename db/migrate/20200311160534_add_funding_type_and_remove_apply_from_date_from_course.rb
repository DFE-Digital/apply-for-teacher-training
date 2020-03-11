class AddFundingTypeAndRemoveApplyFromDateFromCourse < ActiveRecord::Migration[6.0]
  def up
    change_table :courses, bulk: true do |t|
      t.string :description
      t.remove :apply_from_date
      t.remove :qualification
    end
  end

  def down
    change_table :courses, bulk: true do |t|
      t.remove :description
      t.datetime :apply_from_date
      t.string :qualification
    end
  end
end
