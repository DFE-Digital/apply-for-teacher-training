class AddApplicationFormsSafeguardingIssueStatus < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :safeguarding_issues_status, :string, null: false, default: 'not_answered_yet'
    add_column :references, :safeguarding_concerns_status, :string, null: false, default: 'not_answered_yet'
  end
end
