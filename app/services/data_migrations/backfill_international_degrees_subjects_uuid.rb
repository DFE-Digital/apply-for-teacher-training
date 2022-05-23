module DataMigrations
  class BackfillInternationalDegreesSubjectsUuid
    TIMESTAMP = 20220519142519
    MANUAL_RUN = false
    AFTER_NEW_DEGREE_FLOW_RELEASE = '2022-05-04T13:51:00Z'.freeze

    def change
      records.find_each do |qualification|
        subject = subject_for(qualification)

        if subject.present?
          qualification.update_columns(
            degree_subject_uuid: subject.id,
          )
        end
      end
    end

    def dry_run
      total = records.select do |record|
        subject_for(record).present?
      end

      # rubocop:disable Rails/Output
      puts "There are #{total.size} international records with subject in the reference data"
      # rubocop:enable Rails/Output
    end

  private

    def records
      ApplicationQualification.degree
      .where.not(institution_country: nil)
      .where('created_at > ?', AFTER_NEW_DEGREE_FLOW_RELEASE)
    end

    def subject_for(qualification)
      Hesa::Subject.find_by_name(qualification.subject)
    end
  end
end
