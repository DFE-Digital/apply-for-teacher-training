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

      subject_report = initialize_subject_report

      application_forms.find_each do |application|
        # We use the original application to determine subjects and states
        # Note: With continuous applications, we no longer differentiate by phase
        subjects = determine_subjects(application)
        states = determine_states([application])

        if candidate_has_no_dominant_subject?(subjects)
          states.each do |state|
            export_rows[:split][state] += 1
            add_subject_report_split_value(subject_report, state, application.candidate.id)
          end
        else
          dominant_subject = dominant_subject(subjects)

          states&.each do |state|
            add_row_values(export_rows, dominant_subject, state)
            add_subject_report_values(subject_report, dominant_subject, state, application.candidate.id)
          end
        end
      end

      export_rows[:total] = export_rows[:primary].merge(export_rows[:secondary]) { |_k, primary_value, secondary_value| primary_value + secondary_value }

      export_rows[:total] = export_rows[:total].merge(export_rows[:split]) { |_k, total_value, split_value| total_value + split_value }

      write_subject_report(subject_report)

      export_rows.map { |subject, value| { subject: }.merge!(value) }
    end

    alias data_for_export call

    def determine_states(applications)
      choice_statuses = applications.reduce([]) do |results, application|
        results + current_application_choices_for(application).map(&:status).map(&:to_sym)
      end

      # get the highest-ranking status according to the order of precedence
      overall_status = (choice_statuses & MinisterialReport::TAD_STATUS_PRECEDENCE.keys).min_by { |el| MinisterialReport::TAD_STATUS_PRECEDENCE.keys.index(el) }

      mapped = MinisterialReport::TAD_STATUS_PRECEDENCE[overall_status].presence || []
      mapped + [:candidates] # every form is counted as a candidate
    end

  private

    def current_application_choices_for(application_form)
      application_form.application_choices.select do |application_choice|
        application_choice.current_recruitment_cycle_year == current_year
      end
    end



    def add_row_values(hash, subject, state)
      hash[:stem][state] += 1 if MinisterialReport::STEM_SUBJECTS.include? subject
      hash[:ebacc][state] += 1 if MinisterialReport::EBACC_SUBJECTS.include? subject
      hash[:secondary][state] += 1 if MinisterialReport::SECONDARY_SUBJECTS.include? subject
      hash[subject][state] += 1
    end

    def add_subject_report_values(
      subject_report,
      dominant_subject,
      state,
      candidate_id
    )
      if generate_diagnostic_report?
        subject_report[dominant_subject][state] << candidate_id

        if MinisterialReport::STEM_SUBJECTS.include? dominant_subject
          subject_report[:stem][state] << candidate_id
        end
        if MinisterialReport::EBACC_SUBJECTS.include? dominant_subject
          subject_report[:ebacc][state] << candidate_id
        end
        if MinisterialReport::SECONDARY_SUBJECTS.include? dominant_subject
          subject_report[:secondary][state] << candidate_id
        end
      end
    end

    def add_subject_report_split_value(subject_report, state, candidate_id)
      if generate_diagnostic_report?
        subject_report[:split][state] << candidate_id
      end
    end

    def initialize_subject_report_subject(subject_report, subject)
      if subject_report[subject].blank?
        subject_report[subject] = column_names.keys.index_with { [] }
      end
    end

    def add_subject_report_totals(subject_report)
      subject_report[:total] = subject_report[:primary].merge(subject_report[:secondary]) { |_k, primary_value, secondary_value| primary_value + secondary_value }
      subject_report[:total] = subject_report[:total].merge(subject_report[:split]) { |_k, total_value, split_value| total_value + split_value }
    end

    def determine_subjects(application_form)
      current_application_choices_for(application_form).map do |application_choice|
        MinisterialReport.determine_dominant_course_subject_for_report(
          application_choice.current_course,
        )
      end
    end

    def candidate_has_no_dominant_subject?(mapped_subjects)
      return false if mapped_subjects.one? || mapped_subjects.uniq.one?

      count_of_subject_choices(mapped_subjects).values.max <= (mapped_subjects.count / 2)
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
        .includes(:candidate, application_choices: { current_course: :subjects })
        .where(application_choices: { current_recruitment_cycle_year: current_year })
        .where(phase: 'apply_1')
        .or(
          ApplicationForm
            .joins(application_choices: { current_course: :subjects })
            .joins(:candidate)
            .where('application_forms.recruitment_cycle_year < ?', current_year)
            .where('application_choices.current_recruitment_cycle_year' => current_year),
        ).where.not(submitted_at: nil)
        .where.not(candidates: { hide_in_reporting: true })
        .distinct
    end

    def generate_diagnostic_report?
      ENV['GENERATE_MINISTERIAL_REPORTS_DIAGNOSTICS'] == 'true'
    end

    def initialize_subject_report
      subject_report = {}

      if generate_diagnostic_report?
        MinisterialReport::SUBJECTS.each { |subject| initialize_subject_report_subject(subject_report, subject) }
        initialize_subject_report_subject(subject_report, :split)
        initialize_subject_report_subject(subject_report, :total)
      end

      subject_report
    end

    def write_subject_report(subject_report)
      if generate_diagnostic_report?
        add_subject_report_totals(subject_report)
        File.write(
          "subjects-#{Time.zone.now.to_s.gsub(/ \+\d+/, '').gsub(' ', '-').gsub(':', '')}.json",
          subject_report.to_json(indent: 2),
        )
      end
    end

    def current_year
      @current_year ||= RecruitmentCycleTimetable.current_year
    end
  end
end
