class CascadeDeleteUCASMatches < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key 'ucas_matches', 'candidates'
    add_foreign_key 'ucas_matches', 'candidates', on_delete: :cascade
  end
end
