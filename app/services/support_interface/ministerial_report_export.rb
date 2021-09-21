module SupportInterface
  class MinisterialReportExport
    SUBJECT_CODE_MAPPINGS = {
      '00' => :primary,
      '01' => :primary,
      '02' => :primary,
      '03' => :primary,
      '04' => :primary,
      '06' => :primary,
      '07' => :primary,
      'W1' => :art_and_design,
      'F0' => :physics,
      'F3' => :physics,
      'C1' => :biology,
      '08' => :business_studies,
      'L1' => :business_studies,
      'F1' => :chemistry,
      '09' => :other,
      'P3' => :other,
      'L5' => :other,
      'P1' => :other,
      'C8' => :other,
      '14' => :other,
      '41' => :other,
      'Q8' => :classics,
      '11' => :computing,
      '12' => :physical_education,
      'C6' => :physical_education,
      'DT' => :design_and_technology,
      '13' => :drama,
      'Q3' => :english,
      'F8' => :geography,
      'V1' => :history,
      'G1' => :mathematics,
      'W3' => :music,
      'V6' => :religious_education,
      '15' => :modern_foreign_languages,
      '16' => :modern_foreign_languages,
      '17' => :modern_foreign_languages,
      '18' => :modern_foreign_languages,
      '19' => :modern_foreign_languages,
      '20' => :modern_foreign_languages,
      '21' => :modern_foreign_languages,
      '22' => :modern_foreign_languages,
      '24' => :modern_foreign_languages,
    }.freeze

    STATUS_MAPPING = {
      unsubmitted: %i[applications],
      awaiting_provider_decision: %i[applications],
      offer: %i[applications offer_received],
      pending_conditions: %i[applications offer_received accepted],
      rejected: %i[applications application_rejected],
      cancelled: %i[applications application_declined],
      offer_deferred: %i[applications offer_received accepted],
      interviewing: %i[applications],
      offer_withdrawn: %i[applications application_withdrawn],
      conditions_not_met: %i[applications offer_received],
      declined: %i[applications application_declined],
      recruited: %i[applications offer_received accepted],
      withdrawn: %i[applications application_withdrawn],
    }.freeze

    def call
      results = subject_mapping(subject_status_count)

      rows = {}

      Subject::SUBJECTS.each do |subject|
        rows[subject] = {
          applications: 0,
          offer_received: 0,
          accepted: 0,
          application_declined: 0,
          application_rejected: 0,
          application_withdrawn: 0,
        }
      end

      results.each do |key, count|
        subject, status = key

        mapped_statuses = STATUS_MAPPING[status]

        mapped_statuses.each do |mapped_status|
          rows[:stem][mapped_status] += count if Subject::STEM_SUBJECTS.include? subject
          rows[:ebacc][mapped_status] += count if Subject::EBACC_SUBJECTS.include? subject
          rows[:secondary][mapped_status] += count if Subject::SECONDARY_SUBJECTS.include? subject
          rows[subject][mapped_status] += count
        end
      end

      rows[:total] = rows[:primary].merge(rows[:secondary]) { |_k, primary_value, secondary_value| primary_value + secondary_value }

      rows = rows.map { |subject, value| { subject: subject }.merge!(value) }
    end

    alias data_for_export call

  private

    def subject_status_count
      Subject
        .joins(courses: :application_choices)
        .group('subjects.code', 'application_choices.status')
        .count
    end

    def subject_mapping(query)
      query.transform_keys { |subject_code, status| [SUBJECT_CODE_MAPPINGS[subject_code], status.to_sym] }
    end
  end
end
