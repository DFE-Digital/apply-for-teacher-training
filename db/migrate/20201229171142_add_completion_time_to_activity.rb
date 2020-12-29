class AddCompletionTimeToActivity < ActiveRecord::Migration[6.0]
  def change
    add_column :activities, :completion_time, :interval
  end
end
