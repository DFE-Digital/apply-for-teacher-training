module SupportInterface
  class MinisterialReportApplicationsExport
    def self.run_daily
      data_export = DataExport.create!(
        name: 'Daily export of the applications ministerial report',
        export_type: :ministerial_report_applications_export,
      )
      DataExporter.perform_async(SupportInterface::MinisterialReportApplicationsExport.to_s, data_export.id)
    end

    def call(*)
      report = initialize_empty_report
      subject_ids_report = {}

      report = choices_with_courses_and_subjects.each_with_object(report) do |choice, report_in_progress|
        add_choice_to_report(choice, report_in_progress, subject_ids_report)
      end

      assign_totals_to_report(report)
    end

    def add_choice_to_report(choice, report, subject_ids_report)
      return report if choice.phase == 'apply_2' && !choice.is_latest_a2_app

      subject_names_and_codes = choice.subject_names.zip(choice.subject_codes)
      subject = MinisterialReport.determine_dominant_subject_for_report(choice.course_name, choice.course_level, subject_names_and_codes.to_h)
      mapped = MinisterialReport::TAD_STATUS_PRECEDENCE[choice.status.to_sym].presence || []

      (mapped + [:applications]).each do |mapped_status|
        if MinisterialReport::STEM_SUBJECTS.include? subject
          report[:stem][mapped_status] += 1
          add_choice_to_ids_report(subject_ids_report, :stem, mapped_status, choice)
        end
        if MinisterialReport::EBACC_SUBJECTS.include? subject
          report[:ebacc][mapped_status] += 1
          add_choice_to_ids_report(subject_ids_report, :ebacc, mapped_status, choice)
        end
        if MinisterialReport::SECONDARY_SUBJECTS.include? subject
          report[:secondary][mapped_status] += 1
          add_choice_to_ids_report(subject_ids_report, :secondary, mapped_status, choice)
        end
        report[subject][mapped_status] += 1
        add_choice_to_ids_report(subject_ids_report, subject, mapped_status, choice)
      end

      report
    end

    def add_choice_to_ids_report(subject_ids_report, subject, mapped_status, choice)
      if generate_diagnostic_report?
        subject_ids_report[subject] ||= {}
        subject_ids_report[subject][mapped_status] ||= []
        subject_ids_report[subject][mapped_status] << choice.id
      end
    end

    def assign_totals_to_report(report)
      report[:total] = report[:primary].merge(report[:secondary]) { |_k, primary_value, secondary_value| primary_value + secondary_value }

      report.map { |subject, value| { subject: }.merge!(value) }
    end

    alias data_for_export call

  private

    def initialize_empty_report
      report_columns = {
        applications: 0,
        offer_received: 0,
        accepted: 0,
        application_declined: 0,
        application_rejected: 0,
        application_withdrawn: 0,
      }

      report_rows = {}
      MinisterialReport::SUBJECTS.each { |subject| report_rows[subject] = report_columns.dup }

      report_rows
    end

    def generate_diagnostic_report?
      ENV['GENERATE_MINISTERIAL_REPORTS_DIAGNOSTICS'] == 'true'
    end

    def choices_with_courses_and_subjects
      ApplicationChoice
        .select('application_choices.id as id, application_choices.status as status, application_form.id as application_form_id, application_form.phase as phase, courses.name as course_name, courses.level as course_level, ARRAY_AGG(subjects.name ORDER BY subjects.id) as subject_names, ARRAY_AGG(subjects.code ORDER BY subjects.id) as subject_codes, (CASE WHEN a2_latest_application_forms.candidate_id IS NOT NULL THEN true ELSE false END) AS is_latest_a2_app')
        .joins(application_form: :candidate)
        .joins(current_course_option: { course: :subjects })
        .joins(
          "LEFT JOIN (SELECT candidate_id, MAX(created_at) as created
          FROM application_forms
          WHERE phase = 'apply_2'
            AND submitted_at IS NOT NULL
          GROUP BY candidate_id) a2_latest_application_forms
            ON application_form.created_at = a2_latest_application_forms.created
            AND application_form.candidate_id = a2_latest_application_forms.candidate_id",
        )
        .where(current_recruitment_cycle_year:)
        .where.not(application_form: { submitted_at: nil })
        .where.not(candidates: { hide_in_reporting: true })
        .group('application_choices.id, application_choices.status, application_form.id, application_form.phase, courses.name, courses.level, a2_latest_application_forms.candidate_id')
        .order(:subject_names, :subject_codes)
    end

    def current_recruitment_cycle_year
      @current_recruitment_cycle_year ||= RecruitmentCycleTimetable.current_year
    end
  end
end
