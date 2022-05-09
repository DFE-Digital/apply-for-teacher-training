class AddTempSiteToCourseOption < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :course_options, :temp_site, index: { algorithm: :concurrently }
  end
end
