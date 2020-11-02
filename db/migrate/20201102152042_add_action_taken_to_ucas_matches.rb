class AddActionTakenToUCASMatches < ActiveRecord::Migration[6.0]
  def change
    add_column :ucas_matches, :action_taken, :string
  end
end
