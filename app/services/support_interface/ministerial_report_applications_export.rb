module SupportInterface
  class MinisterialReportApplicationsExport
    def self.run_daily
      data_export = DataExport.create!(
        name: 'Daily export of the applications ministerial report',
        export_type: :ministerial_report_applications_export,
      )
      DataExporter.perform_async(SupportInterface::MinisterialReportApplicationsExport, data_export.id)
    end

    def call
      results = subject_mapping(subject_status_count)

      export_rows = {}

      MinisterialReport::SUBJECTS.each { |subject| export_rows[subject] = column_names }

      results.each do |key, count|
        subject, status = key

        mapped_statuses = MinisterialReport::APPLICATIONS_REPORT_STATUS_MAPPING[status]

        mapped_statuses.each { |mapped_status| add_row_values(export_rows, subject, mapped_status, count) }
      end

      export_rows[:total] = export_rows[:primary].merge(export_rows[:secondary]) { |_k, primary_value, secondary_value| primary_value + secondary_value }

      export_rows = export_rows.map { |subject, value| { subject: subject }.merge!(value) }
    end

    alias data_for_export call

  private

    def column_names
      {
        applications: 0,
        offer_received: 0,
        accepted: 0,
        application_declined: 0,
        application_rejected: 0,
        application_withdrawn: 0,
      }
    end

    def add_row_values(hash, subject, status, value)
      hash[:stem][status] += value if MinisterialReport::STEM_SUBJECTS.include? subject
      hash[:ebacc][status] += value if MinisterialReport::EBACC_SUBJECTS.include? subject
      hash[:secondary][status] += value if MinisterialReport::SECONDARY_SUBJECTS.include? subject
      hash[subject][status] += value
    end

    def subject_status_count
      Subject
        .joins(courses: { application_choices: :application_form })
        .where.not('application_forms.submitted_at': nil)
        .group('subjects.code', 'application_choices.status')
        .count
    end

    def subject_mapping(query)
      query.transform_keys { |subject_code, status| [MinisterialReport::SUBJECT_CODE_MAPPINGS[subject_code], status.to_sym] }
    end
  end
end
