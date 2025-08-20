module SupportInterface
  class ApplicationsBySubjectRouteAndDegreeGradeExport
    COLUMNS = %i[
      applications
      offers_received
      number_of_acceptances
      number_of_declined_applications
      number_of_rejected_applications
      number_of_withdrawn_applications
    ].freeze

    def self.run_weekly
      data_export = DataExport.create!(
        name: 'Weekly export of the applications export grouped by subject, route and degree grade',
        export_type: :applications_by_subject_route_and_degree_grade,
      )
      DataExporter.perform_async(SupportInterface::ApplicationsBySubjectRouteAndDegreeGradeExport.to_s, data_export.id)
    end

    def call(*)
      report = choices_with_courses_and_subjects.find_each(batch_size: 100).map do |choice|
        subject = MinisterialReport.determine_dominant_subject_for_report(
          choice.course_name,
          choice.course_level,
          choice.subject_names.zip(choice.subject_codes).to_h,
        )

        {
          subject:,
          route: choice.route,
          grade_hesa_code: choice.grade_hesa_codes.compact.min,
          applications: 0,
          offers_received: 0,
          number_of_acceptances: 0,
          number_of_declined_applications: 0,
          number_of_rejected_applications: 0,
          number_of_withdrawn_applications: 0,
          course_name: choice.course_name,
          course_level: choice.course_level,
          subject_names: choice.subject_names,
          subject_codes: choice.subject_codes,
          status: choice.status,
        }
      end

      report = sort_and_group_by_subject_route_and_grade(report)

      report.map do |key, report_data_objects|
        report_data_objects.each do |data_object|
          status = data_object[:status].to_sym
          MinisterialReport::APPLICATIONS_BY_SUBJECT_ROUTE_AND_DEGREE_GRADE_REPORT_STATUS_MAPPING.fetch(status, []).each do |mapped_status|
            report[key].first[mapped_status] += 1
          end
        end
      end

      report = remove_non_report_columns(report)

      remove_zero_value_rows(report)

      report
    end

    alias data_for_export call

  private

    def remove_non_report_columns(report)
      report.values.flatten.map { |row| row.except(:course_name, :course_level, :subject_names, :subject_codes, :status) }
    end

    def remove_zero_value_rows(report)
      report.reject! { |row| COLUMNS.all? { |key| row[key].zero? } }
    end

    def sort_and_group_by_subject_route_and_grade(report)
      report = report.compact.uniq.flatten.sort_by { |row| row[:subject] }
      report.group_by { |hash| grouping_key(hash) }
    end

    def grouping_key(hash)
      hash[:subject].to_s + hash[:route].to_s + hash[:grade_hesa_code].to_s
    end

    def choices_with_courses_and_subjects
      ApplicationChoice
        .select(
          'application_choices.id as id,
          application_choices.status as status,
          providers.provider_type as route,
          ARRAY_AGG(application_qualifications.grade_hesa_code) as grade_hesa_codes,
          application_form.id as application_form_id,
          application_form.phase as phase,
          courses.name as course_name,
          courses.level as course_level,
          ARRAY_AGG(subjects.name ORDER BY subjects.id) as subject_names,
          ARRAY_AGG(subjects.code ORDER BY subjects.id) as subject_codes',
        )
        .joins(application_form: :application_qualifications)
        .joins(course_option: { course: :provider })
        .joins(course_option: { course: :subjects })
        .where(application_form: { recruitment_cycle_year: RecruitmentCycleTimetable.current_year })
        .where(application_form: { application_qualifications: { level: 'degree' } })
        .where.not(application_form: { submitted_at: nil })
        .group(
          'application_choices.id',
          'application_form.id',
          'courses.name',
          'courses.level',
          'status',
          'providers.provider_type',
          'subjects.name',
          'subjects.code',
        )
    end
  end
end
