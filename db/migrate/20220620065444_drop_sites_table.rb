class DropSitesTable < ActiveRecord::Migration[7.0]
  def change
    safety_assured { drop_table :sites }
  end
end
