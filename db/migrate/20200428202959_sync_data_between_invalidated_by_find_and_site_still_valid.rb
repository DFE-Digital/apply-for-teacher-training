class SyncDataBetweenInvalidatedByFindAndSiteStillValid < ActiveRecord::Migration[6.0]
  def up
    execute('UPDATE course_options SET site_still_valid = NOT invalidated_by_find')
  end

  def down
    execute('UPDATE course_options SET site_still_valid = true')
  end
end
