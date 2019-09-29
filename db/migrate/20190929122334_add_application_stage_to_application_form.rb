class AddApplicationStageToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_reference :application_forms, :application_stage
  end
end
