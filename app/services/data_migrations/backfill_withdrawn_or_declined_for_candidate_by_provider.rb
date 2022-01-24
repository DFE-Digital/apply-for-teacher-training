module DataMigrations
  class BackfillWithdrawnOrDeclinedForCandidateByProvider
    TIMESTAMP = 20220120161816
    MANUAL_RUN = false

    def change
      audits_joins_sql = <<-SQL.squish
        INNER JOIN audits ON audits.auditable_type = 'ApplicationChoice'
        AND audits.auditable_id = application_choices.id
        AND audits.user_type = 'ProviderUser'
        AND audits.comment IN ('Declined on behalf of the candidate', 'Withdrawn on behalf of the candidate')
      SQL

      provider_actor_applications = ApplicationChoice
                                       .joins(audits_joins_sql)
                                       .where('application_choices.status': %w[declined withdrawn])
                                       .distinct

      other_actor_applications = ApplicationChoice
                                   .where.not(id: provider_actor_applications.pluck(:id))
                                   .where(status: %w[declined withdrawn])
                                   .distinct

      provider_actor_applications.update_all(withdrawn_or_declined_for_candidate_by_provider: true)
      other_actor_applications.update_all(withdrawn_or_declined_for_candidate_by_provider: false)
    end
  end
end
