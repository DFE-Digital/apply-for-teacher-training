class AddQualificationAndFinancialSupportColumnsToCourses < ActiveRecord::Migration[6.0]
  def change
    change_table :courses, bulk: true do |t|
      t.string :qualification
      t.string :financial_support
    end
  end
end
