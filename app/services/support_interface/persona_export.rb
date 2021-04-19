module SupportInterface
  class PersonaExport
    include GeocodeHelper

    def data_for_export
      application_choices.find_each(batch_size: 100).map do |application_choice|
        application_form = application_choice.application_form

        {
          candidate_id: application_form.candidate_id,
          support_reference: application_form.support_reference,
          age: return_age(application_form),
          candidate_postcode: application_form.postcode,
          provider_postcode: application_choice.provider.postcode,
          site_postcode: application_choice.site.postcode,
          site_region: application_choice.site.region,
          provider_type: application_choice.provider.provider_type,
          accrediting_provider_type: application_choice.course.accredited_provider&.provider_type,
          program_type: application_choice.course.program_type,
          degree_award_year: return_latest_degree_award_year(application_form),
          degree_type: return_latest_degree_type(application_form),
          distance_from_site_to_candidate: distance(application_choice),
          average_distance_from_all_sites: average_distance(application_form),
          rejection_reason: application_choice.rejection_reason,
          structured_rejection_reasons: FlatReasonsForRejectionPresenter.build_top_level_reasons(application_choice.structured_rejection_reasons),
          application_state: I18n.t!("candidate_flow_application_states.#{ProcessState.new(application_form).state}.name"),
          course_code: application_choice.course.code,
          provider_code: application_choice.provider.code,
          nationality: nationality(application_choice),
          rejected_by_default_at: application_choice.reject_by_default_at,
          link_to_application: application_url(application_form),
        }
      end
    end

  private

    def application_choices
      ApplicationChoice
      .includes(%i[application_form site provider course candidate])
      .joins(:candidate)
      .merge(Candidate.order(:id))
    end

    def return_age(application_form)
      ((Time.zone.now.to_date - application_form.date_of_birth) / 365).floor if application_form.date_of_birth.present?
    end

    def return_latest_degree_type(application_form)
      latest_degree(application_form)&.qualification_type
    end

    def return_latest_degree_award_year(application_form)
      latest_degree(application_form)&.award_year
    end

    def latest_degree(application_form)
      degrees_with_award_year = application_form.application_qualifications.degree.select { |degree| degree.award_year.present? }

      return nil if degrees_with_award_year.blank?

      degrees_with_award_year.max_by(&:award_year)
    end

    def distance(application_choice)
      format_distance(
        application_choice.application_form,
        application_choice&.site, with_units: false
      )
    end

    def average_distance(application_form)
      format_average_distance(
        application_form,
        application_form.application_choices.map(&:site),
        with_units: false,
      )
    end

    def nationality(application_choice)
      ApplicationChoiceHesaExportDecorator.new(application_choice).nationality
    end

    def application_url(application_form)
      "https://www.apply-for-teacher-training.service.gov.uk/support/applications/#{application_form.id}"
    end
  end
end
