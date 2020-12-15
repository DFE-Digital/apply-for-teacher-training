class RemoveMatchingStateFromUCASMatches < ActiveRecord::Migration[6.0]
  def change
    remove_column :ucas_matches, :matching_state, :string
  end
end
