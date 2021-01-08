require 'rails_helper'

RSpec.describe SupportInterface::QualificationsExport do
  include CourseOptionHelpers
  describe '#data_for_export' do
    it 'returns an array of hashes for candidates containing information about their qualifications' do
      candidate_one = create(:candidate)
      course_option_one = course_option_for_provider_code(provider_code: 'ZZ7')
      course_option_two = course_option_for_provider_code(provider_code: 'AA1')
      application_form_one = create(:completed_application_form, candidate: candidate_one)
      application_choice_one = create(:application_choice, status: 'offer', course_option: course_option_one, application_form: application_form_one)
      application_choice_two = create(:application_choice, status: 'rejected', rejection_reason: 'cut of jib', course_option: course_option_two, application_form: application_form_one)

      create(:application_qualification,
             application_form: application_form_one,
             level: 'gcse',
             subject: 'maths',
             grade: 'A')
      create(:application_qualification,
             application_form: application_form_one,
             level: 'gcse',
             subject: 'science',
             grade: 'A*BB')
      create(:application_qualification,
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
             level: 'degree',
             qualification_type: 'BA Memes',
             grade: 'First class honours')

      candidate_two = create(:candidate)
      course_option_three = course_option_for_provider_code(provider_code: 'BB8')
      application_form_two = create(:completed_application_form, candidate: candidate_two)
      application_choice_three = create(:application_choice, status: 'offer', course_option: course_option_three, application_form: application_form_two)

      create(:application_qualification,
             application_form: application_form_two,
             level: 'gcse',
             subject: 'maths',
             grade: 'A')
      create(:application_qualification,
             application_form: application_form_two,
             level: 'gcse',
             subject: 'science double award',
             grade: 'A*A*')
      create(:application_qualification,
             application_form: application_form_two,
             level: 'gcse',
             subject: 'english',
             structured_grades: '{"english_language":"E","english_literature":"E","Cockney Rhyming Slang":"A*"}')
      create(:application_qualification,
             application_form: application_form_two,
             qualification_type: 'A level',
             subject: 'Philosophy',
             level: 'other',
             grade: 'D')
      create(:application_qualification,
             application_form: application_form_two,
             qualification_type: 'AS level',
             subject: 'Trout Fishing',
             level: 'other',
             grade: 'A')
      create(:application_qualification,
             application_form: application_form_two,
             level: 'degree',
             qualification_type: 'BA Welding',
             grade: 'First class honours')

      expect(described_class.new.data_for_export).to contain_exactly(
        {
          'Candidate id' => application_form_one.candidate_id,
          'Support ref' => application_form_one.support_reference,
          'Phase' => application_form_one.phase,
          'Cycle' => application_form_one.recruitment_cycle_year,
          'Outcome (offer, rejected etc.)' => application_choice_one.status,
          'Reason for Rejection' => application_choice_one.rejection_reason,
          'Course Code' => course_option_one.course.code,
          'Provider Code' => 'ZZ7',
          'GCSE maths grade' => 'A',
          'GCSE science single grade' => nil,
          'GCSE science double grade' => nil,
          'GCSE science triple grade' => 'A*BB',
          'GCSE English unstructured grade' => 'C',
          'GCSE English single grade' => nil,
          'GCSE English double grade' => nil,
          'GCSE English language grade' => nil,
          'GCSE English literature grade' => nil,
          'GCSE English studies single grade' => nil,
          'GCSE English studies double grade' => nil,
          'GCSE English other grade' => nil,
          'A level 1 subject' => 'Music',
          'A level 1 grade' => 'D',
          'A level 2 subject' => 'Origami',
          'A level 2 grade' => 'A',
          'A level 3 subject' => nil,
          'A level 3 grade' => nil,
          'A level 4 subject' => nil,
          'A level 4 grade' => nil,
          'A level 5 subject' => nil,
          'A level 5 grade' => nil,
          'Degree 1 type' => 'BA Memes',
          'Degree 1 grade' => 'First class honours',
          'Degree 2 type' => nil,
          'Degree 2 grade' => nil,
          'Number of other qualifications provided' => 2,
        },
        {
          'Candidate id' => application_form_one.candidate_id,
          'Support ref' => application_form_one.support_reference,
          'Phase' => application_form_one.phase,
          'Cycle' => application_form_one.recruitment_cycle_year,
          'Outcome (offer, rejected etc.)' => application_choice_two.status,
          'Reason for Rejection' => application_choice_two.rejection_reason,
          'Course Code' => course_option_two.course.code,
          'Provider Code' => 'AA1',
          'GCSE maths grade' => 'A',
          'GCSE science single grade' => nil,
          'GCSE science double grade' => nil,
          'GCSE science triple grade' => 'A*BB',
          'GCSE English unstructured grade' => 'C',
          'GCSE English single grade' => nil,
          'GCSE English double grade' => nil,
          'GCSE English language grade' => nil,
          'GCSE English literature grade' => nil,
          'GCSE English studies single grade' => nil,
          'GCSE English studies double grade' => nil,
          'GCSE English other grade' => nil,
          'A level 1 subject' => 'Music',
          'A level 1 grade' => 'D',
          'A level 2 subject' => 'Origami',
          'A level 2 grade' => 'A',
          'A level 3 subject' => nil,
          'A level 3 grade' => nil,
          'A level 4 subject' => nil,
          'A level 4 grade' => nil,
          'A level 5 subject' => nil,
          'A level 5 grade' => nil,
          'Degree 1 type' => 'BA Memes',
          'Degree 1 grade' => 'First class honours',
          'Degree 2 type' => nil,
          'Degree 2 grade' => nil,
          'Number of other qualifications provided' => 2,
        },
        {
          'Candidate id' => application_form_two.candidate_id,
          'Support ref' => application_form_two.support_reference,
          'Phase' => application_form_two.phase,
          'Cycle' => application_form_two.recruitment_cycle_year,
          'Outcome (offer, rejected etc.)' => application_choice_three.status,
          'Reason for Rejection' => application_choice_three.rejection_reason,
          'Course Code' => course_option_three.course.code,
          'Provider Code' => 'BB8',
          'GCSE maths grade' => 'A',
          'GCSE science single grade' => nil,
          'GCSE science double grade' => 'A*A*',
          'GCSE science triple grade' => nil,
          'GCSE English unstructured grade' => nil,
          'GCSE English single grade' => nil,
          'GCSE English double grade' => nil,
          'GCSE English language grade' => 'E',
          'GCSE English literature grade' => 'E',
          'GCSE English studies single grade' => nil,
          'GCSE English studies double grade' => nil,
          'GCSE English other grade' => 'A*',
          'A level 1 subject' => 'Philosophy',
          'A level 1 grade' => 'D',
          'A level 2 subject' => 'Trout Fishing',
          'A level 2 grade' => 'A',
          'A level 3 subject' => nil,
          'A level 3 grade' => nil,
          'A level 4 subject' => nil,
          'A level 4 grade' => nil,
          'A level 5 subject' => nil,
          'A level 5 grade' => nil,
          'Degree 1 type' => 'BA Welding',
          'Degree 1 grade' => 'First class honours',
          'Degree 2 type' => nil,
          'Degree 2 grade' => nil,
          'Number of other qualifications provided' => 2,
        },
      )
    end
  end
end
