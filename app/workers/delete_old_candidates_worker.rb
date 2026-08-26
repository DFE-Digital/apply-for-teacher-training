class DeleteOldCandidatesWorker < ApplicationJob
  def perform
    Candidate.where('last_signed_in_at < ?', 7.years.ago).find_in_batches(batch_size: 100) do |batch|
      DeleteCandidatesWorker.perform_later(batch.map(&:id))
    end
  end
end

class DeleteCandidatesWorker < ApplicationJob
  def perform(candidate_ids)
    analytics_tables = YAML.load_file('config/analytics.yml').fetch('shared').keys.map(&:to_s)

    Candidate.where(id: candidate_ids).each do |candidate|
      ActiveRecord::Base.transaction do
        sql_records = sql_cascade_records(candidate)
        rails_records = rails_dependent_records(candidate)

        deleted_records = sql_records.merge(rails_records.except(*sql_records.keys))
                           .slice(*analytics_tables)
                           .compact_blank

        DeletedCandidate.create!(candidate_id: candidate.id, deleted_records:)
        candidate.without_auditing do
          candidate.destroy!
        end
      end
    end
  end

private

  def sql_cascade_records(candidate)
    sql = "WITH RECURSIVE cascade_tree AS (
      -- direct children: FKs pointing at candidates with ON DELETE CASCADE
      SELECT
        con.conrelid  AS child_oid,
        con.confrelid AS parent_oid,
        (SELECT string_agg(pg_attribute.attname, ', ' ORDER BY u.ord)
          FROM unnest(con.conkey) WITH ORDINALITY u(attnum, ord)
          JOIN pg_attribute ON pg_attribute.attrelid = con.conrelid
                             AND pg_attribute.attnum = u.attnum) AS fk_column,
        1 AS depth,
        ARRAY[con.oid] AS seen
      FROM pg_constraint con
      WHERE con.contype = 'f'            -- foreign key
        AND con.confdeltype = 'c'        -- ON DELETE CASCADE
        AND con.confrelid = 'candidates'::regclass

      UNION ALL

      -- find the children of the tables we already found, and keep going recursively.
      SELECT
        con.conrelid,
        tree.child_oid,
        (SELECT string_agg(pg_attribute.attname, ', ' ORDER BY u.ord)
          FROM unnest(con.conkey) WITH ORDINALITY u(attnum, ord)
          JOIN pg_attribute ON pg_attribute.attrelid = con.conrelid
                             AND pg_attribute.attnum = u.attnum) AS fk_column,
        tree.depth + 1,
        tree.seen || con.oid
      FROM pg_constraint con
      JOIN cascade_tree tree ON con.confrelid = tree.child_oid
      WHERE con.contype = 'f'
        AND con.confdeltype = 'c'
        AND con.oid <> ALL (tree.seen)   -- guard against constraint cycles
    )

    SELECT
      cascade_tree.depth,
      child.relname  AS child_table,
      parent.relname AS parent_table,
      cascade_tree.fk_column
    FROM cascade_tree
    JOIN pg_class child  ON child.oid  = cascade_tree.child_oid
    JOIN pg_class parent ON parent.oid = cascade_tree.parent_oid
    ORDER BY depth, child_table;"
    conn = ActiveRecord::Base.connection
    results = conn.execute(sql)
    hash = { 'candidates' => [candidate.id] }

    results.each do |result|
      child_table = result['child_table']
      parent_table = result['parent_table']
      fk_columns = result['fk_column'].split(', ').map { |column| conn.quote_column_name(column) } # map in case we have composite fk
      parent_ids = hash[parent_table].map { |id| conn.quote(Integer(id)) }

      if parent_ids.present?
        sql = "SELECT id FROM #{conn.quote_table_name(child_table)} WHERE #{fk_columns.join(', ')} IN (#{parent_ids.join(', ')})"
        hash[child_table] = conn.execute(sql).values.flatten
      else
        hash[child_table] = []
      end
    end

    hash
  end

  def rails_dependent_records(candidate)
    hash = {}

    sub = ActiveSupport::Notifications.subscribe('sql.active_record') do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)
      sql = event.payload[:sql]

      if sql.start_with?('DELETE FROM')
        table_name = sql.split('DELETE FROM').last.split('WHERE').first&.strip&.delete('"')
        id = if event.payload[:type_casted_binds].any?
               event.payload[:type_casted_binds].first
             else
               sql.split("DELETE FROM \"#{table_name}\" WHERE \"#{table_name}\".\"id\" = ").last.split.first.to_i
             end

        if hash[table_name].present?
          hash[table_name] << id if hash[table_name].exclude?(id)
        else
          hash[table_name] = [id]
        end
      end
    end

    begin
      ActiveRecord::Base.transaction do
        candidate.destroy!
        raise ActiveRecord::Rollback
      end
    ensure
      ActiveSupport::Notifications.unsubscribe(sub)
    end

    hash
  end
end
