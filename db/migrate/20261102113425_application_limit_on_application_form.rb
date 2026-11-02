class ApplicationLimitOnApplicationForm < ActiveRecord::Migration[8.1]
  def change
    add_column(:application_forms, :applications_limit, :integer)
  end
end
