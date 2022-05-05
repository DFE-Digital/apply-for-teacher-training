class AddFeeAndSalaryInformationToCourses < ActiveRecord::Migration[7.0]
  def change
    add_column :courses, :fee_details, :string
    add_column :courses, :fee_international, :integer
    add_column :courses, :fee_domestic, :integer
    add_column :courses, :salary_details, :string
  end
end
