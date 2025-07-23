class RemoveClosedCourseFromInvites < ActiveRecord::Migration[8.0]
  def change
    safety_assured { remove_column :pool_invites, :course_closed, :boolean, default: false }
  end
end
