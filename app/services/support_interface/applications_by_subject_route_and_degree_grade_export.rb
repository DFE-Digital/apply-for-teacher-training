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
      DataExporter.perform_async(SupportInterface::ApplicationsBySubjectRouteAndDegreeGradeExport, data_export.id)
    end

    def call(*)
      report = choices_with_courses_and_subjects.find_each(batch_size: 100).map do |choice|
        next if choice.phase == 'apply_2' && !choice.is_latest_a2_app

        subject = MinisterialReport.determine_dominant_course_subject_for_report(choice.course_name, choice.course_level, choice.subject_names.zip(choice.subject_codes).to_h)

        {
          subject: subject,
          route: choice.route,
          degree_class: choice.degree_class,
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

      report.map do |key, ary|
        ary.each do |hash|
          MinisterialReport::APPLICATIONS_BY_SUBJECT_ROUTE_AND_DEGREE_GRADE_REPORT_STATUS_MAPPING[hash[:status].to_sym].each do |mapped_status|
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
      hash[:subject].to_s + hash[:route].to_s + hash[:degree_class].to_s
    end

    def choices_with_courses_and_subjects
      ApplicationChoice
        .select('application_choices.id as id, application_choices.status as status, providers.provider_type as route, application_qualifications.grade as degree_class, application_form.id as application_form_id, application_form.phase as phase, courses.name as course_name, courses.level as course_level, ARRAY_AGG(subjects.name) as subject_names, ARRAY_AGG(subjects.code) as subject_codes, (CASE WHEN a2_latest_application_forms.candidate_id IS NOT NULL THEN true ELSE false END) AS is_latest_a2_app')
        .joins(application_form: :application_qualifications)
        .joins(course_option: { course: :provider })
        .joins(course_option: { course: :subjects })
        .joins("LEFT JOIN (SELECT candidate_id, MAX(created_at) as created FROM application_forms WHERE phase = 'apply_2' GROUP BY candidate_id) a2_latest_application_forms ON application_form.created_at = a2_latest_application_forms.created AND application_form.candidate_id = a2_latest_application_forms.candidate_id")
        .where(application_form: { recruitment_cycle_year: RecruitmentCycle.current_year })
        .where(application_form: { application_qualifications: { level: 'degree' } })
        .where.not(application_form: { submitted_at: nil })
        .group('application_choices.id', 'application_form.id', 'a2_latest_application_forms.candidate_id', 'courses.name', 'courses.level', 'status', 'providers.provider_type', 'subjects.name', 'subjects.code', 'application_qualifications.grade')
    end
  end
end
