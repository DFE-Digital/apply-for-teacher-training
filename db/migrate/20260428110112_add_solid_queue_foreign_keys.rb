class AddSolidQueueForeignKeys < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :solid_queue_blocked_executions, :solid_queue_jobs,
                    column: :job_id, on_delete: :cascade, validate: false

    add_foreign_key :solid_queue_claimed_executions, :solid_queue_jobs,
                    column: :job_id, on_delete: :cascade, validate: false

    add_foreign_key :solid_queue_failed_executions, :solid_queue_jobs,
                    column: :job_id, on_delete: :cascade, validate: false

    add_foreign_key :solid_queue_ready_executions, :solid_queue_jobs,
                    column: :job_id, on_delete: :cascade, validate: false

    add_foreign_key :solid_queue_recurring_executions, :solid_queue_jobs,
                    column: :job_id, on_delete: :cascade, validate: false

    add_foreign_key :solid_queue_scheduled_executions, :solid_queue_jobs,
                    column: :job_id, on_delete: :cascade, validate: false
  end
end
