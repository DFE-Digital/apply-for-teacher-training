class ConvertStatusEnumToString < ActiveRecord::Migration[6.0]
  def change
    change_column(:application_choices, :status, :string)
  end
end
