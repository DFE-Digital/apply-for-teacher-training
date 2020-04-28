class RenameInvalidatedByFindToSiteStillValidOnCourseOptions < ActiveRecord::Migration[6.0]
  def change
    rename_column :course_options, :invalidated_by_find, :site_still_valid
  end
end
