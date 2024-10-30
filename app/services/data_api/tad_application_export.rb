module DataAPI
  class TADApplicationExport
    attr_reader :application_choice

    delegate :application_form, to: :application_choice
    delegate :candidate, to: :application_form

    def initialize(application_choice)
      @application_choice = application_choice
    end

    # Documented in app/exports/tad_export.yml
    def as_json
      accrediting_provider = application_choice.current_accredited_provider || application_choice.current_provider
      degree = application_form.application_qualifications.find { |q| q.level == 'degree' }
      equality_and_diversity = application_form.equality_and_diversity.to_h

      {
        extract_date: Time.zone.now.iso8601,

        # Internal identifiers
        candidate_id: application_form.candidate.id,
        application_choice_id: application_choice.id,
        application_form_id: application_form.id,

        # State
        status:,
        phase: application_form.phase,
        submitted_at: application_form.submitted_at.iso8601,

        # Personal information
        first_name: application_form.first_name,
        last_name: application_form.last_name,
        date_of_birth: application_form.date_of_birth,
        email: candidate.email_address,
        postcode: application_form.postcode,
        country: application_form.country,
        nationality: concatenate(nationalities),

        # HESA data
        sex: equality_and_diversity['hesa_sex'],
        disability: equality_and_diversity['hesa_disabilities'],
        ethnicity: equality_and_diversity['hesa_ethnicity'],

        # The candidate's degree
        degree_classification: degree&.grade,
        degree_classification_hesa_code: degree&.grade_hesa_code,

        # Provider
        provider_code: application_choice.current_provider.code,
        provider_id: application_choice.current_provider.id,
        provider_name: application_choice.current_provider.name,
        accrediting_provider_code: accrediting_provider.code,
        accrediting_provider_id: accrediting_provider.id,
        accrediting_provider_name: accrediting_provider.name,

        course_level: application_choice.current_course.level,
        program_type: application_choice.current_course.program_type,
        programme_outcome: application_choice.current_course.description,
        course_name: application_choice.current_course.name,
        course_code: application_choice.current_course.code,
        nctl_subject: concatenate(application_choice.current_course.subjects.map(&:code)),
        offer_deferred_at: application_choice.offer_deferred_at&.iso8601,
        offer_originally_deferred_at:,
        offer_reconfirmed_at: application_choice_deferred_confirmed_at,
        offer_reconfirmed_cycle_year: application_choice_deferred_confirmed_at.present? ? CycleTimetable.current_year(application_choice_deferred_confirmed_at) : nil,
        recruitment_cycle_year: application_choice.recruitment_cycle,
        accepted_at: application_choice.accepted_at&.iso8601,
        withdrawn_at: application_choice.withdrawn_at&.iso8601,
      }
    end

  private

    def status
      if application_choice.rejected_by_default?
        'rejected_by_default'
      elsif application_choice.declined_by_default?
        'declined_by_default'
      else
        application_choice.status
      end
    end

    def nationalities
      [
        application_form.first_nationality,
        application_form.second_nationality,
        application_form.third_nationality,
        application_form.fourth_nationality,
        application_form.fifth_nationality,
      ].map { |n| NATIONALITIES_BY_NAME[n] }.compact.uniq
        .sort.partition { |e| %w[GB IE].include? e }.flatten
    end

    def concatenate(array)
      array.to_a.join('|')
    end

    def offer_originally_deferred_at
      return if application_choice.offer_deferred_at.nil?

      # We get the audits in the order they have been created, first record is the oldest
      old_attributes = audits.map(&:old_attributes)
      # [nil, nil, timestamp]
      first_deferred_at = old_attributes.map do |attributes|
        attributes[:offer_deferred_at]
      end.compact.first

      original_deferred_at = first_deferred_at || application_choice.offer_deferred_at
      original_deferred_at.to_time.iso8601
    end

    def application_choice_deferred_confirmed_at
      return if application_choice.offer_deferred_at.nil?

      audit_when_deferred_offer_has_been_confirmed = audits.to_a.select do |audit|
        audit.audited_changes['status'] == %w[offer_deferred recruited]
      end.last

      if audit_when_deferred_offer_has_been_confirmed.present?
        audit_when_deferred_offer_has_been_confirmed.created_at.iso8601
      end
    end

    def audits
      @audits ||= application_choice.audits
    end
  end
end
