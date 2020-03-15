class ScrubEqualityAndDiversityAudits < ActiveRecord::Migration[6.0]
  def up
    # See https://www.postgresql.org/docs/current/functions-json.html
    Audited::Audit.where(
      # in this field       get this key            as jsonb
      "(audited_changes -> 'equality_and_diversity')::jsonb" +
      # audited saves changes as pairs of [before, after], get index 1 (after)
      '->1' +
      # do any of these strings exist as top-level keys?
      " ?| array['sex', 'disabilities', 'ethnic_group', 'ethnic_background']",
    ).destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
