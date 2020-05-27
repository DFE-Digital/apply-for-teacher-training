class BackfillApplicationReferencesSafeguardingConcernsStatus < ActiveRecord::Migration[6.0]
  def up
    execute "UPDATE \"references\" SET safeguarding_concerns_status = 'never_asked' WHERE feedback_status IN ('feedback_provided', 'feedback_refused') AND (safeguarding_concerns IS NULL)"
    execute "UPDATE \"references\" SET safeguarding_concerns_status = 'no_safeguarding_concerns_to_declare' WHERE safeguarding_concerns = ''"
    execute "UPDATE \"references\" SET safeguarding_concerns_status = 'has_safeguarding_concerns_to_declare' WHERE NOT safeguarding_concerns = '' AND safeguarding_concerns IS NOT NULL"
  end

  def down
    execute "UPDATE \"references\" SET safeguarding_concerns_status = 'not_answered_yet'"
  end
end
