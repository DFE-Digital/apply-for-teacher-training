require 'rails_helper'

RSpec.describe SupportInterface::FlatReasonsForRejectionPresenter, type: :presenter do
  let(:application_choice) do
    create(
      :application_choice,
      :with_structured_rejection_reasons,
    )
  end

  describe '.build_from_structured_rejection_reasons.new' do
    it 'creates an object based on the provided rejected ApplicationChoice' do
      flat_rejection_reasons = described_class.build_from_structured_rejection_reasons(ReasonsForRejection.new(application_choice.structured_rejection_reasons))

      expect(flat_rejection_reasons).to eq(
        {
          something_you_did: true,
          didn_t_reply_to_our_interview_offer: true,
          didn_t_attend_interview: true,
          something_you_did_other_reason_details: 'Persistent scratching',
          candidate_behaviour_what_to_improve: 'Not scratch so much',
          quality_of_application: true,
          personal_statement: true,
          personal_statement_what_to_improve: 'Use a spellchecker',
          subject_knowledge: true,
          subject_knowledge_what_to_improve: 'Claiming to be the \'world\'s leading expert\' seemed a bit strong',
          quality_of_application_what_to_improve: 'Study harder',
          quality_of_application_other_reason_details: 'Lights on but nobody home',
          qualifications: true,
          no_maths_gcse_grade_4_c_or_above_or_valid_equivalent: false,
          no_english_gcse_grade_4_c_or_above_or_valid_equivalent: true,
          no_science_gcse_grade_4_c_or_above_or_valid_equivalent_for_primary_applicants: false,
          no_degree: false,
          qualifications_other_reason_details: 'All the other stuff',
          performance_at_interview: true,
          performance_at_interview_what_to_improve: 'Be fully dressed',
          course_full: false,
          they_offered_you_a_place_on_another_course: false,
          offered_on_another_course_details: nil,
          honesty_and_professionalism: true,
          information_given_on_application_form_false_or_inaccurate: true,
          information_given_on_application_form_false_or_inaccurate_details: 'Fake news',
          evidence_of_plagiarism_in_personal_statement_or_elsewhere: false,
          evidence_of_plagiarism_in_personal_statement_or_elsewhere_details: nil,
          references_didn_t_support_application: true,
          references_didn_t_support_application_details: 'Clearly not a popular student',
          honesty_and_professionalism_other_reason_details: nil,
          safeguarding_issues: true,
          information_disclosed_by_candidate_makes_them_unsuitable_to_work_with_children: false,
          information_disclosed_by_candidate_makes_them_unsuitable_to_work_with_children_details: nil,
          information_revealed_by_our_vetting_process_makes_the_candidate_unsuitable_to_work_with_children: false,
          information_revealed_by_our_vetting_process_makes_the_candidate_unsuitable_to_work_with_children_details: nil,
          safeguarding_issues_other_reason_details: 'We need to run further checks',
          visa_application_sponsorship: false,
          cannot_sponsor_visa_details: nil,
          additional_advice: false,
          future_applications: false,
          why_are_you_rejecting_this_application_details: nil,
        },
      )
    end
  end

  describe '.build_top_level_reasons' do
    it 'creates a string containing the rejection reasons' do
      rejection_export_line = described_class.build_top_level_reasons(application_choice.structured_rejection_reasons)

      expect(rejection_export_line).to eq(
        'Something you did, Honesty and professionalism, Performance at interview, Qualifications, Quality of application, Safeguarding issues',
      )
    end
  end
end
