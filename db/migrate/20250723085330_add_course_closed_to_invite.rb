class AddCourseClosedToInvite < ActiveRecord::Migration[8.0]
  def change
    add_column :pool_invites, :course_closed, :boolean, default: false
  end
end
