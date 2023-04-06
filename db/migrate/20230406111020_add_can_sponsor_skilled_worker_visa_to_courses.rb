class AddCanSponsorSkilledWorkerVisaToCourses < ActiveRecord::Migration[7.0]
  def change
    add_column :courses, :can_sponsor_skilled_worker_visa, :boolean
  end
end
