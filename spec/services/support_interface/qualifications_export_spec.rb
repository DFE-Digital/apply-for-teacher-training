require 'rails_helper'

RSpec.describe SupportInterface::QualificationsExport do
  include CourseOptionHelpers

  describe 'documentation' do
    before do
      application_form = create(:completed_application_form, candidate: create(:candidate))
      create(:application_choice, status: 'offer', application_form: application_form)
      create(:gcse_qualification,
             application_form: application_form,
             subject: 'maths',
             grade: 'A')
    end

    it_behaves_like 'a data export'
  end

  describe '#data_for_export' do
    it 'returns an array of hashes for candidates containing information about their qualifications' do
      candidate_one = create(:candidate)
      course_option_one = course_option_for_provider_code(provider_code: 'AA1')
      course_option_two = course_option_for_provider_code(provider_code: 'ZZ7')
      application_form_one = create(:completed_application_form, candidate: candidate_one)
      application_choice_one = create(:application_choice, status: 'rejected', structured_rejection_reasons: {
        quality_of_application_y_n: 'Yes',
        quality_of_application_which_parts_needed_improvement: %w[personal_statement subject_knowledge],
        quality_of_application_personal_statement_what_to_improve: 'Do not refer to yourself in the third person',
        quality_of_application_subject_knowledge_what_to_improve: 'Write in the first person',
      },
                                                           course_option: course_option_one, application_form: application_form_one)
      create(:application_choice, status: 'offer', course_option: course_option_two, application_form: application_form_one)

      create(:gcse_qualification,
             application_form: application_form_one,
             subject: 'maths',
             grade: 'A')
      create(:gcse_qualification,
             application_form: application_form_one,
             subject: 'science',
             grade: 'A*BB')
      create(:gcse_qualification,
             application_form: application_form_one,
             level: 'gcse',
             subject: 'english',
             grade: 'C')
      create(:application_qualification,
             application_form: application_form_one,
             qualification_type: 'A level',
             subject: 'Music',
             level: 'other',
             grade: 'D')
      create(:application_qualification,
             application_form: application_form_one,
             qualification_type: 'AS level',
             subject: 'Origami',
             level: 'other',
             grade: 'A')
      create(:application_qualification,
             application_form: application_form_one,
             qualification_type: 'AS level',
             subject: nil,
             level: 'other',
             grade: 'A')
      create(:degree_qualification,
             application_form: application_form_one,
             qualification_type: 'BA Memes',
             grade: 'First class honours')
      create(:degree_qualification,
             application_form: application_form_one,
             subject: nil,
             qualification_type: 'BA',
             grade: '2:1')

      candidate_two = create(:candidate)
      course_option_three = course_option_for_provider_code(provider_code: 'BB8')
      application_form_two = create(:completed_application_form, candidate: candidate_two)
      create(:application_choice, status: 'rejected', rejection_reason: 'Cut of jib', course_option: course_option_three, application_form: application_form_two)

      create(:gcse_qualification,
             application_form: application_form_two,
             level: 'gcse',
             subject: 'maths',
             grade: 'A')
      create(:gcse_qualification,
             application_form: application_form_two,
             level: 'gcse',
             subject: 'science double award',
             grade: 'A*A*')
      create(:gcse_qualification,
             application_form: application_form_two,
             level: 'gcse',
             subject: 'english',
             constituent_grades: { english_language: { grade: 'E' }, english_literature: { grade: 'E' }, "Cockney Rhyming Slang": { grade: 'A*' } })
      create(:application_qualification,
             application_form: application_form_two,
             qualification_type: 'A level',
             subject: 'Philosophy',
             level: 'other',
             grade: 'D')
      create(:degree_qualification,
             application_form: application_form_two,
             qualification_type: 'AS level',
             subject: 'Trout Fishing',
             level: 'other',
             grade: 'A')
      create(:degree_qualification,
             application_form: application_form_two,
             level: 'degree',
             qualification_type: 'BA Welding',
             grade: 'First class honours')

      expect(described_class.new.data_for_export).to contain_exactly(
        {
          candidate_id: application_form_one.candidate_id,
          support_reference: application_form_one.support_reference,
          phase: application_form_one.phase,
          recruitment_cycle_year: application_form_one.recruitment_cycle_year,
          choice_status: 'rejected',
          rejection_reason: application_choice_one.structured_rejection_reasons,
          course_code: course_option_one.course.code,
          provider_code: 'AA1',
          gcse_maths_grade: 'A',
          gcse_science_single_grade: nil,
          gcse_science_double_grade: nil,
          gcse_science_triple_grade: 'A*BB',
          gcse_english_unstructured_grade: 'C',
          gcse_english_single_grade: nil,
          gcse_english_double_grade: nil,
          gcse_english_language_grade: nil,
          gcse_english_literature_grade: nil,
          gcse_english_studies_single_grade: nil,
          gcse_english_studies_double_grade: nil,
          gcse_english_other_grade: nil,
          a_level_1_subject: 'Music',
          a_level_1_grade: 'D',
          a_level_2_subject: 'Origami',
          a_level_2_grade: 'A',
          a_level_3_subject: nil,
          a_level_3_grade: nil,
          a_level_4_subject: nil,
          a_level_4_grade: nil,
          a_level_5_subject: nil,
          a_level_5_grade: nil,
          degree_1_type: 'BA Memes',
          degree_1_grade: 'First class honours',
          degree_2_type: nil,
          degree_2_grade: nil,
          number_of_other_qualifications_provided: 3,
        },
        {
          candidate_id: application_form_one.candidate_id,
          support_reference: application_form_one.support_reference,
          phase: application_form_one.phase,
          recruitment_cycle_year: application_form_one.recruitment_cycle_year,
          choice_status: 'offer',
          rejection_reason: nil,
          course_code: course_option_two.course.code,
          provider_code: 'ZZ7',
          gcse_maths_grade: 'A',
          gcse_science_single_grade: nil,
          gcse_science_double_grade: nil,
          gcse_science_triple_grade: 'A*BB',
          gcse_english_unstructured_grade: 'C',
          gcse_english_single_grade: nil,
          gcse_english_double_grade: nil,
          gcse_english_language_grade: nil,
          gcse_english_literature_grade: nil,
          gcse_english_studies_single_grade: nil,
          gcse_english_studies_double_grade: nil,
          gcse_english_other_grade: nil,
          a_level_1_subject: 'Music',
          a_level_1_grade: 'D',
          a_level_2_subject: 'Origami',
          a_level_2_grade: 'A',
          a_level_3_subject: nil,
          a_level_3_grade: nil,
          a_level_4_subject: nil,
          a_level_4_grade: nil,
          a_level_5_subject: nil,
          a_level_5_grade: nil,
          degree_1_type: 'BA Memes',
          degree_1_grade: 'First class honours',
          degree_2_type: nil,
          degree_2_grade: nil,
          number_of_other_qualifications_provided: 3,
        },
        {
          candidate_id: application_form_two.candidate_id,
          support_reference: application_form_two.support_reference,
          phase: application_form_two.phase,
          recruitment_cycle_year: application_form_two.recruitment_cycle_year,
          choice_status: 'rejected',
          rejection_reason: 'Cut of jib',
          course_code: course_option_three.course.code,
          provider_code: 'BB8',
          gcse_maths_grade: 'A',
          gcse_science_single_grade: nil,
          gcse_science_double_grade: 'A*A*',
          gcse_science_triple_grade: nil,
          gcse_english_unstructured_grade: nil,
          gcse_english_single_grade: nil,
          gcse_english_double_grade: nil,
          gcse_english_language_grade: 'E',
          gcse_english_literature_grade: 'E',
          gcse_english_studies_single_grade: nil,
          gcse_english_studies_double_grade: nil,
          gcse_english_other_grade: 'A*',
          a_level_1_subject: 'Philosophy',
          a_level_1_grade: 'D',
          a_level_2_subject: 'Trout Fishing',
          a_level_2_grade: 'A',
          a_level_3_subject: nil,
          a_level_3_grade: nil,
          a_level_4_subject: nil,
          a_level_4_grade: nil,
          a_level_5_subject: nil,
          a_level_5_grade: nil,
          degree_1_type: 'BA Welding',
          degree_1_grade: 'First class honours',
          degree_2_type: nil,
          degree_2_grade: nil,
          number_of_other_qualifications_provided: 2,
        },
      )
    end
  end
end
