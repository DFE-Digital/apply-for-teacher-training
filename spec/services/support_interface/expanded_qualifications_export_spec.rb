require 'rails_helper'

RSpec.describe SupportInterface::ExpandedQualificationsExport do
  include CourseOptionHelpers

  describe '#data_for_export' do
    it 'returns an array of hashes with details about all qualifications and their related course choices' do
      candidate = create(:candidate)
      application_form = create(:completed_application_form, candidate:)
      course_option_one = course_option_for_provider_code(provider_code: 'AA1')
      course_option_two = course_option_for_provider_code(provider_code: 'ZZ7')
      choice_one = create(:application_choice, course_option: course_option_one, application_form:)
      choice_two = create(:application_choice, course_option: course_option_two, application_form:)
      qualification_one = create(
        :gcse_qualification, application_form:, subject: 'maths', grade: 'A'
      )
      qualification_two = create(
        :degree_qualification, application_form:, subject: 'english', qualification_type: 'BA', grade: '2:1'
      )

      expect(described_class.new.data_for_export).to contain_exactly(
        row_data(application_form, choice_one, qualification_one),
        row_data(application_form, choice_one, qualification_two),
        row_data(application_form, choice_two, qualification_one),
        row_data(application_form, choice_two, qualification_two),
      )
    end

    def row_data(application_form, choice, qualification)
      {
        application_form_id: application_form.id,
        qualification_id: qualification.id,
        candidate_id: application_form.candidate.id,
        support_reference: application_form.support_reference,
        phase: application_form.phase,
        recruitment_cycle_year: application_form.recruitment_cycle_year,

        choice_status: choice.status,
        course_code: choice.course.code,
        provider_code: choice.course.provider.code,

        level: qualification.level,
        qualification_type: qualification.qualification_type,
        other_uk_qualification_type: qualification.other_uk_qualification_type,
        award_year: qualification.award_year,
        subject: qualification.subject,
        predicted_grade: qualification.predicted_grade,
        grade: qualification.grade,
        constituent_grades: qualification.constituent_grades,
        international_degree: qualification.international,
        non_uk_qualification_type: qualification.non_uk_qualification_type,
        qualification_institution_name: qualification.institution_name,
        qualification_institution_country: qualification.institution_country,
        comparable_uk_degree: qualification.comparable_uk_degree,
        comparable_uk_qualification: qualification.comparable_uk_qualification,
      }
    end
  end
end
