module DataMigrations
  class BackfillExportType
    TIMESTAMP = 20210326113829
    MANUAL_RUN = false

    def change
      data_exports = DataExport.select(:id, :name, :export_type).where(export_type: nil)

      data_exports.find_in_batches(batch_size: 10).with_index do |batch, batch_number|
        Rails.logger.info("Updating DataExport export_types, batch no. #{batch_number}...")
        batch.each { |export| export.update!(export_type: export_type_lookup.fetch(export.name)) }
      end
    end

  private

    def export_type_lookup
      @export_type_lookup ||= {
        'Unexplained breaks in work history' => 'work_history_break',
        'Locations' => 'persona_export',
        'Locations export' => 'persona_export',
        'Applications for TAD' => 'tad_applications',
        'Provider performance for TAD' => 'tad_provider_performance',
        'Candidate survey' => nil,
        'Daily export of applications for TAD' => nil,
        'Daily export of notifications breakdown' => nil,
        'RejectedCandidatesExport' => nil,
        'Active provider user permissions' => 'active_provider_user_permissions',
        'Active provider users' => 'active_provider_users',
        'Application references' => 'application_references',
        'Application timings' => 'application_timings',
        'Candidate application feedback' => 'candidate_application_feedback',
        'Candidate autosuggest usage' => 'candidate_autosuggest_usage',
        'Candidate email send counts' => 'candidate_email_send_counts',
        'Candidate feedback' => 'candidate_feedback',
        'Candidate journey tracking' => 'candidate_journey_tracking',
        'Candidate course choice withdrawal survey' => 'candidate_course_choice_withdrawal_survey',
        'Equality and diversity data' => 'equality_and_diversity',
        'Interview changes' => 'interview_export',
        'Notes' => 'notes_export',
        'Notifications' => 'notifications_export',
        'Offer conditions' => 'offer_conditions',
        'Organisation permissions' => 'organisation_permissions',
        'Provider Access Controls' => 'provider_access_controls',
        'Providers' => 'providers_export',
        'Persona data' => 'persona_export',
        'Qualifications' => 'qualifications',
        'Referee survey' => 'referee_survey',
        'Sites' => 'sites_export',
        'Structured reasons for rejection' => 'structured_reasons_for_rejection',
        'Submitted application choices' => 'submitted_application_choices',
        'TAD applications' => 'tad_applications',
        'TAD provider performance' => 'tad_provider_performance',
        'User permissions' => 'user_permissions',
        'Work history break' => 'work_history_break',
      }
    end
  end
end
