module SupportInterface
  class MinisterialReportCandidatesExport
    def self.run_daily
      data_export = DataExport.create!(
        name: 'Daily export of the candidates ministerial report',
        export_type: :ministerial_report_candidates_export,
      )
      DataExporter.perform_async(SupportInterface::MinisterialReportCandidatesExport, data_export.id)
    end

    def call(*)
      export_rows = {}

      MinisterialReport::SUBJECTS.each { |subject| export_rows[subject] = column_names }

      export_rows[:split] = column_names

      application_forms.find_each do |application|
        next if application.phase == 'apply_2'

        subjects = determine_subjects(application)

        states = if candidate_has_a_successful_apply_2_application?(application)
                   determine_states(application.candidate.current_application)
                 else
                   determine_states(application)
                 end

        if candidate_has_no_dominant_subject?(subjects)
          states.each { |state| export_rows[:split][state] += 1 }
        else
          dominant_subject = dominant_subject(subjects)

          states&.each { |state| add_row_values(export_rows, dominant_subject, state) }
        end
      end

      export_rows[:total] = export_rows[:primary].merge(export_rows[:secondary]) { |_k, primary_value, secondary_value| primary_value + secondary_value }

      export_rows[:total] = export_rows[:total].merge(export_rows[:split]) { |_k, total_value, split_value| total_value + split_value }

      export_rows.map { |subject, value| { subject: subject }.merge!(value) }
    end

    alias data_for_export call

    def determine_states(application)
      choice_statuses = application.application_choices.map(&:status)

      if choice_statuses.any? { |choice_status| %w[pending_conditions offer_deferred recruited].include? choice_status }
        MinisterialReport::CANDIDATES_REPORT_STATUS_MAPPING[:pending_conditions]
      elsif choice_statuses.any? { |choice_status| %w[offer conditions_not_met].include? choice_status }
        MinisterialReport::CANDIDATES_REPORT_STATUS_MAPPING[:offer]
      elsif choice_statuses.any? { |choice_status| %w[awaiting_provider_decision interviewing].include? choice_status }
        MinisterialReport::CANDIDATES_REPORT_STATUS_MAPPING[:awaiting_provider_decision]
      elsif choice_statuses.any? { |choice_status| %w[offer_withdrawn].include? choice_status }
        MinisterialReport::CANDIDATES_REPORT_STATUS_MAPPING[:offer_withdrawn]
      elsif choice_statuses.any? { |choice_status| %w[cancelled declined].include? choice_status }
        MinisterialReport::CANDIDATES_REPORT_STATUS_MAPPING[:declined]
      elsif choice_statuses.any? { |choice_status| %w[rejected].include? choice_status }
        MinisterialReport::CANDIDATES_REPORT_STATUS_MAPPING[:rejected]
      elsif choice_statuses.any? { |choice_status| %w[withdrawn].include? choice_status }
        MinisterialReport::CANDIDATES_REPORT_STATUS_MAPPING[:withdrawn]
      end
    end

  private

    def candidate_has_a_successful_apply_2_application?(application)
      application != application.candidate.current_application && application.candidate.current_application.phase == 'apply_2' && determine_states(application.candidate.current_application) == MinisterialReport::CANDIDATES_REPORT_STATUS_MAPPING[:recruited]
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
          application_choice.course,
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
      count_of_subject_choices(subjects).max_by(&:last).first
    end

    def column_names
      {
        candidates: 0,
        candidates_holding_offers: 0,
        candidates_that_have_accepted_offers: 0,
        declined_candidates: 0,
        rejected_candidates: 0,
        candidates_that_have_withdrawn_offers: 0,
      }
    end

    def application_forms
      ApplicationForm
        .joins(application_choices: { course: :subjects })
        .joins(:candidate)
        .where(application_choices: { current_recruitment_cycle_year: RecruitmentCycle.current_year })
        .where.not(submitted_at: nil)
        .where.not(candidates: { hide_in_reporting: true })
        .distinct
    end
  end
end
