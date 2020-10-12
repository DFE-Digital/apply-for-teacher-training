class FixRecruitmentCycleYear < ActiveRecord::Migration[6.0]
  def up
    ApplicationForm.where(recruitment_cycle_year: 2022).each do |application_form|
      application_form.update!(
        recruitment_cycle_year: 2021,
        audit_comment: 'The carry-over code inadvertently marked this as recruitment_cycle_year 2022, not 2021.',
      )
    end
  end

  def down; end
end
