class AddNoAssessmentPlanDetailsToEnglishProficiency < ActiveRecord::Migration[8.1]
  def change
    add_column :english_proficiencies, :no_assessment_plan_details, :text
  end
end
