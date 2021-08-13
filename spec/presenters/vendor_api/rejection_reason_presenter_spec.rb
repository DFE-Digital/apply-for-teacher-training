require 'rails_helper'

RSpec.describe VendorAPI::RejectionReasonPresenter do
  describe '#present' do
    let(:structured_rejection_reasons) do
      {
        candidate_behaviour_y_n: 'Yes',
        candidate_behaviour_what_did_the_candidate_do: %w[other],
        candidate_behaviour_other: 'Mumbled',
        candidate_behaviour_what_to_improve: 'Speak clearly',
        quality_of_application_y_n: 'Yes',
        quality_of_application_which_parts_needed_improvement: %w[personal_statement other],
        quality_of_application_personal_statement_what_to_improve: 'Was too personal',
        quality_of_application_other_details: 'Written in crayon',
        quality_of_application_other_what_to_improve: 'Write with a pen',
        qualifications_y_n: 'Yes',
        qualifications_which_qualifications: %w[no_maths_gcse],
        qualifications_other_details: 'You need maths',
        performance_at_interview_y_n: 'Yes',
        performance_at_interview_what_to_improve: 'Be on time',
        offered_on_another_course_y_n: 'Yes',
        offered_on_another_course_details: 'Cycling proficiency course',
        honesty_and_professionalism_y_n: 'Yes',
        honesty_and_professionalism_concerns: %w[information_false_or_inaccurate plagiarism references other],
        honesty_and_professionalism_concerns_information_false_or_inaccurate_details: 'Lies',
        honesty_and_professionalism_concerns_plagiarism_details: 'Lies were copied',
        honesty_and_professionalism_concerns_references_details: 'Referees cannot be fictional characters',
        honesty_and_professionalism_concerns_other_details: 'A lot of problems here',
        safeguarding_y_n: 'Yes',
        safeguarding_concerns: %w[other],
        safeguarding_concerns_candidate_disclosed_information_details: nil,
        safeguarding_concerns_vetting_disclosed_information_details: nil,
        safeguarding_concerns_other_details: 'You seemed very angry',
        why_are_you_rejecting_this_application: 'So many reasons',
        other_advice_or_feedback_y_n: 'Yes',
        other_advice_or_feedback_details: 'Try again soon',
        interested_in_future_applications_y_n: 'Yes',
      }
    end

    let(:application_choice) do
      build_stubbed(
        :application_choice,
        structured_rejection_reasons: structured_rejection_reasons,
        course_option: course_option,
      )
    end

    let(:course_option) { build_stubbed(:course_option, course: build_stubbed(:course, provider: provider)) }
    let(:provider) { build_stubbed(:provider, name: 'UoG') }

    subject(:presenter) { described_class.new(application_choice) }

    it 'returns a formatted string from structured rejection reasons field' do
      expect(presenter.present.split("\n\n")).to eq([
        "Something you did:\nMumbled\nSpeak clearly",
        "Quality of application:\nWas too personal\nWritten in crayon\nWrite with a pen",
        "Qualifications:\nNo Maths GCSE grade 4 (C) or above, or valid equivalent",
        "Performance at interview:\nBe on time",
        "They offered you a place on another course:\nCycling proficiency course",
        "Honesty and professionalism:\nLies\nLies were copied\nReferees cannot be fictional characters\nA lot of problems here",
        "Safeguarding issues:\nYou seemed very angry",
        "Additional advice:\nTry again soon",
        "Future applications:\nUoG would be interested in future applications from you.",
      ])
    end

    context 'when structured_rejection_reasons are blank' do
      let(:application_choice) { build_stubbed(:application_choice, rejection_reason: 'Course was full') }

      it 'returns the rejection_reason attribute' do
        expect(presenter.present).to eq('Course was full')
      end
    end
  end
end
