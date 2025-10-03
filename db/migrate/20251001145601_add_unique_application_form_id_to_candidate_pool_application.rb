class AddUniqueApplicationFormIdToCandidatePoolApplication < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    if index_exists?(:candidate_pool_applications, :application_form_id)
      remove_index :candidate_pool_applications, column: :application_form_id
    end

    add_index(
      :candidate_pool_applications,
      :application_form_id,
      unique: true,
      algorithm: :concurrently,
    )
  end

  def down
    if index_exists?(:candidate_pool_applications, :application_form_id)
      remove_index :candidate_pool_applications, column: :application_form_id
    end

    add_index(
      :candidate_pool_applications,
      :application_form_id,
      algorithm: :concurrently,
    )
  end
end
