class BackfillApplicationFormsSafeguardingIssuesStatus < ActiveRecord::Migration[6.0]
  def up
    execute "UPDATE application_forms SET safeguarding_issues_status = 'never_asked' WHERE submitted_at IS NOT NULL AND (safeguarding_issues IS NULL OR safeguarding_issues = '')"
    execute "UPDATE application_forms SET safeguarding_issues_status = 'no_safeguarding_issues_to_declare' WHERE safeguarding_issues = 'No'"
    execute "UPDATE application_forms SET safeguarding_issues_status = 'has_safeguarding_issues_to_declare' WHERE NOT safeguarding_issues = 'No' AND safeguarding_issues IS NOT NULL AND NOT safeguarding_issues = ''"
  end

  def down
    execute "UPDATE application_forms SET safeguarding_issues_status = 'not_answered_yet'"
  end
end
