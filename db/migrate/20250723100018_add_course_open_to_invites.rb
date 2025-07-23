class AddCourseOpenToInvites < ActiveRecord::Migration[8.0]
  def change
    add_column :pool_invites, :course_open, :boolean, default: true
  end
end
