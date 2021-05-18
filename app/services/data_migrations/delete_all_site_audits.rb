module DataMigrations
  class DeleteAllSiteAudits
    TIMESTAMP = 20210518152035
    MANUAL_RUN = false

    def change
      Site.in_batches(of: 20).each_with_index do |relation, batch_index|
        site_audits_query =
          Audited::Audit
            .with(sites: relation)
            .joins('INNER JOIN sites ON auditable_type = \'Site\' AND auditable_id = sites.id')
            .select(:id)

        delete_site_audits!(
          audits_sql: site_audits_query.to_sql,
          batch_index: batch_index,
        )
      end
    end

    def delete_site_audits!(audits_sql:, batch_index:)
      delete_sql = <<~DELETE_SITE_AUDITS.squish
        DELETE FROM audits
        WHERE id IN (#{audits_sql})
      DELETE_SITE_AUDITS

      result = ActiveRecord::Base.connection.execute(delete_sql)
      Rails.logger.info("Deleting site audits - batch no. #{batch_index + 1}: #{result.cmd_status}")
    end
  end
end
