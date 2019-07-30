module TestHelpers
  module DegreeDetails
    def fill_in_degree_details
      details = {
        type: 'BA',
        subject: 'Philosophy',
        institution: 'University of London',
        class: 'first',
        year: 2000
      }

      fill_in t('application_form.degree_details_section.type.label'), with: details[:type]
      fill_in t('application_form.degree_details_section.subject.label'), with: details[:subject]
      fill_in t('application_form.degree_details_section.institution.label'), with: details[:institution]
      fill_in t('application_form.degree_details_section.class.label'), with: details[:class]
      fill_in t('application_form.degree_details_section.year.label'), with: details[:year]
    end
  end
end

