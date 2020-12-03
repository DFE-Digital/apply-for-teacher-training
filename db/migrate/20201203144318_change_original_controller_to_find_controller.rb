class ChangeOriginalControllerToFindController < ActiveRecord::Migration[6.0]
  def change
    rename_column :find_feedback, :original_controller, :find_controller
  end
end
