module SupportInterface
  class OfferConditionsExport
    def offers
      relevant_choices.flat_map do |choice|
        {
          support_reference: choice.application_form.support_reference,
          phase: choice.application_form.phase,
          recruitment_cycle: choice.recruitment_cycle,
          qualification_type: qualification_type(choice.application_form),
          qualification_subject: qualification_subject(choice.application_form),
          qualification_grade: qualification_grade(choice.application_form),
          start_year: start_year(choice.application_form),
          award_year: award_year(choice.application_form),
          provider_code: choice.provider.code,
          provider: choice.provider.name,
          course_offered_provider_name: choice.offered_option.provider.name,
          course_offered_course_name: choice.offered_course.name,
          offer_made_at: choice.offered_at.to_s(:govuk_date),
          application_status: choice.status,
          conditions: conditions(choice),
        }
      end
    end

  private

    def qualification_type(form)
      qualifications(form).map(&:level).join(',')
    end

    def qualification_subject(form)
      qualifications(form).map(&:subject).join(',')
    end

    def qualification_grade(form)
      qualifications(form).map(&:grade).join(',')
    end

    def start_year(form)
      qualifications(form).map(&:start_year).join(',')
    end

    def award_year(form)
      qualifications(form).map(&:award_year).join(',')
    end

    def qualifications(form)
      form.application_qualifications.order(:created_at)
    end

    def conditions(choice)
      choice.offer['conditions'].join(',')
    end

    def relevant_choices
      ApplicationChoice
        .where('offer IS NOT NULL')
        .order('offered_at asc')
    end
  end
end
