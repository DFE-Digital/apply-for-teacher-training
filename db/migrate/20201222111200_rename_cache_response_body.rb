class RenameCacheResponseBody < ActiveRecord::Migration[6.0]
  def change
    rename_column :application_response_caches, :response_body, :response
  end
end
