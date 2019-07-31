module TestHelpers
  module NonDegreeQualifications
    def fill_in_qualification_details
      details = {
        type_of_qualification: 'GCSE',
        subject: 'Biology',
        institution: 'Grange Hill School',
        grade: 'D',
        year: 1999
      }

      fill_in t('application_form.qualification_section.type.label'), with: details[:type_of_qualification]
      fill_in t('application_form.qualification_section.subject.label'), with: details[:subject]
      fill_in t('application_form.qualification_section.institution.label'), with: details[:institution]
      fill_in t('application_form.qualification_section.grade.label'), with: details[:grade]
      fill_in t('application_form.qualification_section.year.label'), with: details[:year]
    end
  end
end
