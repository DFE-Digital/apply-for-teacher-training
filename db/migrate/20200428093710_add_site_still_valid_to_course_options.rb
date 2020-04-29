class AddSiteStillValidToCourseOptions < ActiveRecord::Migration[6.0]
  def change
    add_column :course_options, :site_still_valid, :boolean, default: true, null: false
  end
end
