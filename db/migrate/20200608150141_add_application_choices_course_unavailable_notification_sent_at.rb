class AddApplicationChoicesCourseUnavailableNotificationSentAt < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :course_unavailable_notification_sent_at, :datetime
  end
end
