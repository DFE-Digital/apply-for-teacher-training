class CreateFeatureMetricsDashboard < ActiveRecord::Migration[6.0]
  def change
    create_table :feature_metrics_dashboards do |t|
      t.timestamps

      t.float :avg_time_to_get_references
      t.float :avg_time_to_get_references_this_month
      t.float :avg_time_to_get_references_last_month
      t.float :pct_references_completed_within_30_days
      t.float :pct_references_completed_within_30_days_this_month
      t.float :pct_references_completed_within_30_days_last_month

      t.float :avg_time_to_complete_work_history
      t.float :avg_time_to_complete_work_history_this_month
      t.float :avg_time_to_complete_work_history_last_month

      t.float :avg_sign_ins_before_submitting
      t.float :avg_sign_ins_before_submitting_this_month
      t.float :avg_sign_ins_before_submitting_last_month
      t.float :avg_sign_ins_before_offer
      t.float :avg_sign_ins_before_offer_this_month
      t.float :avg_sign_ins_before_offer_last_month
      t.float :avg_sign_ins_before_recruitment
      t.float :avg_sign_ins_before_recruitment_this_month
      t.float :avg_sign_ins_before_recruitment_last_month

      t.integer :num_rejections_due_to_qualifications
      t.integer :num_rejections_due_to_qualifications_this_month
      t.integer :num_rejections_due_to_qualifications_last_month
    end
  end
end
