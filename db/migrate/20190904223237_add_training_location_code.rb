class AddTrainingLocationCode < ActiveRecord::Migration[5.2]
  def change
    add_column :training_locations, :code, :string
  end
end
