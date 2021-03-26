class AddTypeToDataExports < ActiveRecord::Migration[6.0]
  def change
    add_column :data_exports, :export_type, :string
  end
end
