class DeleteOldCandidatesWorker < ApplicationJob
  def perform
    # candidates = Candidate.where('last_signed_in_at < ?', 7.years.ago).find_in_batches(&:destroy_all)

    candidates = Candidate.all
    candidates.find_in_batches(batch_size: 100) do |batch|
      DeleteCandidatesWorker.perform_later(batch)
    end
  end
end

class DeleteCandidatesWorker < ApplicationJob
  def perform(batch)
    analytics_tables = YAML.load_file('config/analytics.yml').fetch('shared').keys.map(&:to_s)

    batch.each do |candidate|
      ActiveRecord::Base.transaction do
        sql_keys = sql_cascade_records(candidate)
        rails_keys = rails_dependent_records(candidate)

        shared_keys = sql_keys.keys & rails_keys.keys
        deleted_records = sql_keys.merge(rails_keys).except(shared_keys).except(analytics_tables).compact_blank

        DeletedCandidate.create!(candidate_id: candidate.id, deleted_records:)
        candidate.destroy!
      end
    end
  end

private

  def sql_cascade_records(candidate)
    sql = "WITH RECURSIVE cascade_tree AS (
      -- direct children: FKs pointing at candidates with ON DELETE CASCADE
      SELECT
        con.conrelid::regclass::text AS child_table,
        con.confrelid::regclass::text AS parent_table,
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

      -- their children, transitively
      SELECT
        con.conrelid::regclass::text,
        tree.child_table,
        (SELECT string_agg(pg_attribute.attname, ', ' ORDER BY u.ord)
          FROM unnest(con.conkey) WITH ORDINALITY u(attnum, ord)
          JOIN pg_attribute ON pg_attribute.attrelid = con.conrelid
                             AND pg_attribute.attnum = u.attnum) AS fk_column,
        tree.depth + 1,
        tree.seen || con.oid
      FROM pg_constraint con
      JOIN cascade_tree tree ON con.confrelid = tree.child_table::regclass
      WHERE con.contype = 'f'
        AND con.confdeltype = 'c'
        AND con.oid <> ALL (tree.seen)   -- guard against constraint cycles
    )

    SELECT depth, child_table, parent_table, fk_column
    FROM cascade_tree
    ORDER BY depth, child_table;"
    results = ActiveRecord::Base.connection.execute(sql)
    hash = { 'candidates' => [candidate.id] }

    results.each do |result|
      child_table = result['child_table']
      parent_table = result['parent_table']
      fk_column = result['fk_column']
      fk_column_ids = hash[parent_table].join(',')

      if fk_column_ids.present?
        sql = "select id from #{child_table} where #{fk_column} IN (#{fk_column_ids})"
        hash[child_table] = ActiveRecord::Base.connection.execute(sql).values.flatten
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
        id = sql.split("DELETE FROM \"#{table_name}\" WHERE \"#{table_name}\".\"id\" = ").last.split.first.to_i

        if hash[table_name].present?
          hash[table_name] << id
        else
          hash[table_name] = [id]
        end
      end
    end

    ActiveRecord::Base.transaction do
      candidate.application_forms&.destroy_all
      raise ActiveRecord::Rollback
    end

    ActiveSupport::Notifications.unsubscribe(sub)
    hash
  end
end
