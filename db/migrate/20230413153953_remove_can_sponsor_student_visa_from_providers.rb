class RemoveCanSponsorStudentVisaFromProviders < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :providers, :can_sponsor_student_visa, :boolean }
  end
end
