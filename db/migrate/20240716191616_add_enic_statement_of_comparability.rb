class AddEnicStatementOfComparability < ActiveRecord::Migration[7.1]
  def change
    add_column :application_qualifications, :enic_reason, :string
  end
end
