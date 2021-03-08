require 'rails_helper'

RSpec.describe FlatReasonsForRejectionPresenter, type: :presenter do
  let(:application_choice) do
    create(
      :application_choice,
      :with_structured_rejection_reasons,
    )
  end

  describe '.build_from_hash' do
    it 'creates an object based on the provided rejected ApplicationChoice' do
      rejection_export = FlatReasonsForRejectionPresenter.build_from_hash(application_choice.structured_rejection_reasons)

      expect(rejection_export).to have_attributes(
        candidate_behaviour: true,
        didnt_reply_to_interview_offer: true,
        didnt_attend_interview: true,
        candidate_behaviour_other_details: 'Persistent scratching',
        candidate_behaviour_what_to_improve_details: 'Not scratch so much',
        quality_of_application: true,
        personal_statement: true,
        quality_of_application_personal_statement_what_to_improve: 'Use a spellchecker',
        subject_knowledge: true,
        quality_of_application_subject_knowledge_what_to_improve_details: 'Claiming to be the \'world\'s leading expert\' seemed a bit strong',
        quality_of_application_other_what_to_improve_details: 'Study harder',
        quality_of_application_other_details: 'Lights on but nobody home',
        qualifications: true,
        no_maths_gcse: false,
        no_english_gcse: true,
        no_science_gcse: false,
        no_degree: false,
        qualifications_other_details: 'All the other stuff',
        performance_at_interview: true,
        performance_at_interview_what_to_improve_details: 'Be fully dressed',
        course_full: false,
        offered_on_another_course: false,
        honesty_and_professionalism: true,
        information_false_or_inaccurate: true,
        honesty_and_professionalism_concerns_information_false_or_inaccurate_details: 'Fake news',
        plagiarism: false,
        honesty_and_professionalism_concerns_plagiarism_details: nil,
        references: true,
        honesty_and_professionalism_concerns_references_details: 'Clearly not a popular student',
        honesty_and_professionalism_concerns_other_details: nil,
        safeguarding: true,
        candidate_disclosed_information: false,
        safeguarding_concerns_candidate_disclosed_information_details: nil,
        vetting_disclosed_information: false,
        safeguarding_concerns_vetting_disclosed_information_details: nil,
        safeguarding_concerns_other_details: 'We need to run further checks',
        other_advice_or_feedback: false,
        interested_in_future_applications: false,
        why_are_you_rejecting_this_application_details: nil,
      )
    end
  end

  describe '.build_high_level' do
    it 'creates a string containing the rejection reasons' do
      rejection_export_line = FlatReasonsForRejectionPresenter.build_high_level(application_choice.structured_rejection_reasons)

      expect(rejection_export_line).to eq(
        "Something you did\nHonesty and professionalism\nPerformance at interview\nQualifications\nQuality of application\nSafeguarding issues",
      )
    end
  end
end
