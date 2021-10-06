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

      multi_subject_choices = multi_subject_application_ids(results)

      previously_mapped_choices = []

      results.each do |(subject, status, id, name, phase, form_id), count|
        next if not_the_latest_apply_2_application?(phase, form_id)

        if multi_subject_choices.include?(id) && unable_to_map_subject_to_course_name?(id, name, subject, previously_mapped_choices)
          subject = ApplicationChoice.find(id).course.level.to_sym
          previously_mapped_choices << id
        elsif previously_mapped_choices.include?(id) || not_the_main_subject?(multi_subject_choices, id, name, subject)
          next
        end

        mapped_statuses = MinisterialReport::APPLICATIONS_REPORT_STATUS_MAPPING[status]

        mapped_statuses.each { |mapped_status| add_row_values(export_rows, subject, mapped_status, count) }
      end

      export_rows[:total] = export_rows[:primary].merge(export_rows[:secondary]) { |_k, primary_value, secondary_value| primary_value + secondary_value }

      export_rows = export_rows.map { |subject, value| { subject: subject }.merge!(value) }
    end

    alias data_for_export call

  private

    def unable_to_map_subject_to_course_name?(application_choice_id, course_name, subject_name, mapped_choices)
      subject_does_not_appear_first(course_name, subject_name) && !subject_appears_in_course_name(course_name, subject_name) && !mapped_choices.include?(application_choice_id)
    end

    def not_the_main_subject?(multi_subject_choices, application_choice_id, course_name, course_subject)
      multi_subject_choices.include?(application_choice_id) && subject_does_not_appear_first(course_name, course_subject) && subject_appears_in_course_name(course_name, course_subject)
    end

    def not_the_latest_apply_2_application?(application_phase, application_form_id)
      application_phase == 'apply_2' && ApplicationForm.find(application_form_id) != ApplicationForm.find(application_form_id).candidate.current_application
    end

    def multi_subject_application_ids(subjects)
      application_choices_ids = []

      subjects.each { |(_subject, _status, id, _name, _phase, _form_id), _count| application_choices_ids << id }

      application_choices_ids.select { |id| application_choices_ids.count(id) > 1 }.uniq
    end

    def subject_does_not_appear_first(course_name, subject_name)
      !course_name.split.first.downcase.in?(subject_name.to_s.downcase)
    end

    def subject_appears_in_course_name(course_name, subject_name)
      subject_name.to_s.downcase.in?(course_name.downcase)
    end

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
        .where('application_forms.recruitment_cycle_year': RecruitmentCycle.current_year)
        .where.not('application_forms.submitted_at': nil)
        .group('subjects.code', 'application_choices.status', 'application_choices.id', 'courses.name', 'application_forms.phase', 'application_forms.id')
        .count
    end

    def subject_mapping(query)
      query.transform_keys { |subject_code, status, id, name, phase, form_id| [MinisterialReport::SUBJECT_CODE_MAPPINGS[subject_code], status.to_sym, id, name, phase, form_id] }
    end
  end
end
