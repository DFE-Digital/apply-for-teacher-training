module SupportInterface
  class LocationsExport
    def data_for_export
      application_choices.map do |application_choice|
        application_form = application_choice.application_form

        {
          'id' => application_form.candidate_id,
          'Age' => return_age(application_form),
          'Candidates postcode' => application_form.postcode,
          'Providers postcode' => application_choice.provider.postcode,
          'Sites postcode' => application_choice.site.postcode,
          'Provider type' => application_choice.provider.provider_type,
          'Accrediting provider type' => application_choice.course.accredited_provider&.provider_type,
          'Program type' => application_choice.course.program_type,
          'Degree completed' => return_lastest_degree_award_year(application_form),
          'Status' => application_state(application_form),
        }
      end
    end

  private

    def application_choices
      ApplicationChoice.all.includes(%i[application_form]).sort_by do |application_choice|
        application_choice.application_form.candidate_id
      end
    end

    def return_age(application_form)
      ((Time.zone.now.to_date - application_form.date_of_birth) / 365).floor
    end

    def application_state(application_form)
      ProcessState.new(application_form).state
    end

    def return_lastest_degree_award_year(application_form)
      application_form.application_qualifications.degree.map(&:award_year).compact.max
    end
  end
end
