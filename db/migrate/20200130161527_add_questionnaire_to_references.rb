class AddQuestionnaireToReferences < ActiveRecord::Migration[6.0]
  def change
    add_column :references, :questionnaire, :jsonb
  end
end
