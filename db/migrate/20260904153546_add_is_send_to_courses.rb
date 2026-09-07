class AddIsSendToCourses < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :is_send, :boolean, default: false
  end
end
