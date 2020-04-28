class ChangeSiteStillValidDefaultValue < ActiveRecord::Migration[6.0]
  def change
    change_column_default :course_options, :site_still_valid, from: false, to: true
  end
end
