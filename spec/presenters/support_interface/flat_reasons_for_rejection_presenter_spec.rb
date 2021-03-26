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
          'Something you did' => true,
          "Didn't reply to our interview offer" => true,
          "Didn't attend interview" => true,
          'Something you did other reason - details' => 'Persistent scratching',
          'Candidate behaviour - what to improve' => 'Not scratch so much',
          'Quality of application' => true,
          'Personal statement' => true,
          'Personal statement - what to improve' => 'Use a spellchecker',
          'Subject knowledge' => true,
          'Subject knowledge - what to improve' => 'Claiming to be the \'world\'s leading expert\' seemed a bit strong',
          'Quality of application - what to improve' => 'Study harder',
          'Quality of application other reason - details' => 'Lights on but nobody home',
          'Qualifications' => true,
          'No Maths GCSE grade 4 (C) or above, or valid equivalent' => false,
          'No English GCSE grade 4 (C) or above, or valid equivalent' => true,
          'No Science GCSE grade 4 (C) or above, or valid equivalent (for primary applicants)' => false,
          'No degree' => false,
          'Qualifications other reason - details' => 'All the other stuff',
          'Performance at interview' => true,
          'Performance at interview - what to improve' => 'Be fully dressed',
          'Course full' => false,
          'They offered you a place on another course' => false,
          'Offered on another course - details' => nil,
          'Honesty and professionalism' => true,
          'Information given on application form false or inaccurate' => true,
          'Information given on application form false or inaccurate - details' => 'Fake news',
          'Evidence of plagiarism in personal statement or elsewhere' => false,
          'Evidence of plagiarism in personal statement or elsewhere - details' => nil,
          "References didn't support application" => true,
          "References didn't support application - details" => 'Clearly not a popular student',
          'Honesty and professionalism other reason - details' => nil,
          'Safeguarding issues' => true,
          'Information disclosed by candidate makes them unsuitable to work with children' => false,
          'Information disclosed by candidate makes them unsuitable to work with children - details' => nil,
          'Information revealed by our vetting process makes the candidate unsuitable to work with children' => false,
          'Information revealed by our vetting process makes the candidate unsuitable to work with children - details' => nil,
          'Safeguarding issues other reason - details' => 'We need to run further checks',
          'Additional advice' => nil,
          'Future applications' => nil,
          'why are you rejecting this application details' => nil,
        },
      )
    end
  end

  describe '.build_top_level_reasons' do
    it 'creates a string containing the rejection reasons' do
      rejection_export_line = described_class.build_top_level_reasons(application_choice.structured_rejection_reasons)

      expect(rejection_export_line).to eq(
        "Something you did\nHonesty and professionalism\nPerformance at interview\nQualifications\nQuality of application\nSafeguarding issues",
      )
    end
  end
end
