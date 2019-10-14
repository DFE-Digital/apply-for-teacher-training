class ConvertApplicationChoiceIdToString < ActiveRecord::Migration[6.0]
  def change
    change_column :application_choices, :id, :string, limit: 10, default: nil
  end
end
