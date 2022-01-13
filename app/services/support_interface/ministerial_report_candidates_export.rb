module SupportInterface
  class MinisterialReportCandidatesExport
    def self.run_daily
      data_export = DataExport.create!(
        name: 'Daily export of the candidates ministerial report',
        export_type: :ministerial_report_candidates_export,
      )
      DataExporter.perform_async(SupportInterface::MinisterialReportCandidatesExport.to_s, data_export.id)
    end

    def call(*)
      export_rows = {}

      MinisterialReport::SUBJECTS.each { |subject| export_rows[subject] = column_names }

      export_rows[:split] = column_names

      subject_report = {}

      application_forms.find_each do |application|
        latest_application =
          if candidate_has_a_viable_apply_2_application?(application)
            application.candidate.current_application
          else
            application
          end
        subjects = determine_subjects(latest_application)
        states = determine_states(latest_application)

        if candidate_has_no_dominant_subject?(subjects)

          if subject_report[:split].blank?
            subject_report[:split] = column_names.keys.index_with { [] }
          end

          states.each do |state|
            export_rows[:split][state] += 1
            subject_report[:split][state] << application.candidate.id
          end
        else
          dominant_subject = dominant_subject(subjects)

          if subject_report[dominant_subject].blank?
            subject_report[dominant_subject] = column_names.keys.index_with { [] }
          end

          states&.each do |state|
            add_row_values(export_rows, dominant_subject, state)
            subject_report[dominant_subject][state] << application.candidate.id
          end
        end
      end

      File.write("subjects-#{Time.zone.now}.txt", subject_report.inspect)

      export_rows[:total] = export_rows[:primary].merge(export_rows[:secondary]) { |_k, primary_value, secondary_value| primary_value + secondary_value }

      export_rows[:total] = export_rows[:total].merge(export_rows[:split]) { |_k, total_value, split_value| total_value + split_value }

      export_rows.map { |subject, value| { subject: subject }.merge!(value) }
    end

    alias data_for_export call

    def determine_states(application)
      choice_statuses = application.application_choices.map(&:status).map(&:to_sym)

      # get the highest-ranking status according to the order of precedence
      overall_status = (choice_statuses & MinisterialReport::TAD_STATUS_PRECEDENCE.keys).min_by { |el| MinisterialReport::TAD_STATUS_PRECEDENCE.keys.index(el) }

      mapped = MinisterialReport::TAD_STATUS_PRECEDENCE[overall_status].presence || []
      mapped + [:candidates] # every form is counted as a candidate
    end

  private

    def candidate_has_a_viable_apply_2_application?(application)
      application != application.candidate.current_application \
        && application.candidate.current_application.phase == 'apply_2' \
        && application.candidate.current_application.submitted_at.present? \
        && !ApplicationStateChange::UNSUCCESSFUL_END_STATES.include?(application.candidate.current_application.application_choices.first.status)
    end

    def add_row_values(hash, subject, state)
      hash[:stem][state] += 1 if MinisterialReport::STEM_SUBJECTS.include? subject
      hash[:ebacc][state] += 1 if MinisterialReport::EBACC_SUBJECTS.include? subject
      hash[:secondary][state] += 1 if MinisterialReport::SECONDARY_SUBJECTS.include? subject
      hash[subject][state] += 1
    end

    def determine_subjects(application_form)
      application_form.application_choices.map do |application_choice|
        MinisterialReport.determine_dominant_course_subject_for_report(
          application_choice.current_course,
        )
      end
    end

    def candidate_has_no_dominant_subject?(mapped_subjects)
      return false if mapped_subjects.count == 1 || mapped_subjects.uniq.size == 1

      return true if count_of_subject_choices(mapped_subjects).values.uniq.size == 1
    end

    def count_of_subject_choices(subjects)
      subjects.tally
    end

    def dominant_subject(subjects)
      total_choice_count = count_of_subject_choices(subjects)
      count_of_subject_choices(subjects).max_by(&:last).first
    end

    def column_names
      {
        candidates: 0,
        offer_received: 0,
        accepted: 0,
        application_declined: 0,
        application_rejected: 0,
        application_withdrawn: 0,
      }
    end

    def application_forms
      ApplicationForm
        .joins(application_choices: { current_course: :subjects })
        .joins(:candidate)
        .where(application_choices: { current_recruitment_cycle_year: RecruitmentCycle.current_year })
        .where.not(submitted_at: nil)
        .where.not(candidates: { hide_in_reporting: true })
        .where(phase: 'apply_1')
        .distinct
    end
  end
end
