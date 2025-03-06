class AddVisaSponsorshipApplicationDeadlineAtToCourse < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :visa_sponsorship_application_deadline_at, :datetime
  end
end
