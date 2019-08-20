module TestHelpers
  module PersonalDetails
    def fill_in_personal_details
      details = {
        first_name: 'John',
        last_name: 'Doe',
        title: 'Dr',
        preferred_name: 'Dr Doe'
      }

      fill_in t('application_form.personal_details_section.title.label'), with: details[:title]
      fill_in t('application_form.personal_details_section.first_name.label'), with: details[:first_name]
      fill_in t('application_form.personal_details_section.preferred_name.label'), with: details[:preferred_name]
      fill_in t('application_form.personal_details_section.last_name.label'), with: details[:last_name]
    end
  end
end
