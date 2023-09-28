require 'rails_helper'

RSpec.describe 'RejectionReasonPresenter' do
  describe '#present' do
    let(:application_reason_presenter) { VendorAPI::RejectionReasonPresenter }
    let(:course_option) { build_stubbed(:course_option, course: build_stubbed(:course, provider:)) }
    let(:provider) { build_stubbed(:provider, name: 'UoG') }
    let(:rejection_reasons_type) { 'reasons_for_rejection' }

    let(:application_choice) do
      build_stubbed(
        :application_choice,
        structured_rejection_reasons:,
        rejection_reasons_type:,
        course_option:,
      )
    end

    subject(:presenter) { application_reason_presenter.new(application_choice) }

    context 'when structured_rejection_reasons are blank' do
      let(:application_choice) { build_stubbed(:application_choice, rejection_reason: 'Course was full') }

      it 'returns the rejection_reason attribute' do
        expect(presenter.present).to eq('Course was full')
      end
    end

    context 'for legacy reasons for rejection' do
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

      it 'returns a formatted string from structured rejection reasons field' do
        expect(presenter.present.split("\n\n")).to eq([
          "Something you did:\nMumbled\nSpeak clearly",
          "Quality of application:\nWas too personal\nWritten in crayon\nWrite with a pen",
          "Qualifications:\nNo Maths GCSE grade 4 (C) or above, or valid equivalent",
          "Performance at interview:\nBe on time",
          "They offered you a place on another course:\nCycling proficiency course",
          "Honesty and professionalism:\nLies\nLies were copied\nReferees cannot be fictional characters\nA lot of problems here",
          "Safeguarding issues:\nYou seemed very angry",
          "Reasons why your application was unsuccessful:\nSo many reasons",
          "Additional advice:\nTry again soon",
          "Future applications:\nUoG would be interested in future applications from you.",
        ])
      end
    end

    context 'current rejection reasons' do
      let(:structured_rejection_reasons) do
        {
          selected_reasons: [
            { id: 'qualifications', label: 'Qualifications', selected_reasons: [
              { id: 'no_maths_gcse', label: 'No maths GCSE at minimum grade 4 or C, or equivalent' },
              { id: 'qualifications_other', label: 'Other', details: { id: 'qualifications_other_details', text: 'Some text about qualifications.' } },
            ] },
            { id: 'personal_statement', label: 'Personal statement', selected_reasons: [
              { id: 'quality_of_writing', label: 'Quality of writing', details: { id: 'quality_of_writing_details', text: 'We could not read your handwriting.' } },
            ] },
            { id: 'references', label: 'References', details: { id: 'references_details', text: 'We cannot accept references from your mother.' } },
            { id: 'course_full', label: 'Course full' },
            { id: 'other', label: 'Other', details: { id: 'other_details', text: 'Some additional details.' } },
          ],
        }
      end

      let(:rejection_reasons_type) { 'rejection_reasons' }

      it 'returns a formatted string from structured rejection reasons field' do
        expect(presenter.present.split("\n\n")).to eq([
          "Qualifications:\nNo maths GCSE at minimum grade 4 or C, or equivalent.\nOther:\nSome text about qualifications.",
          "Personal statement:\nQuality of writing:\nWe could not read your handwriting.",
          "References:\nWe cannot accept references from your mother.",
          "Course full:\nThe course is full.",
          "Other:\nSome additional details.",
        ])
      end
    end

    context 'simple text rejection reason' do
      let(:application_choice) do
        build_stubbed(
          :application_choice,
          structured_rejection_reasons: nil,
          rejection_reason: 'We are sorry, thanks but no thanks.',
          rejection_reasons_type: 'rejection_reason',
          course_option:,
        )
      end

      it 'returns the simple text rejection reason' do
        expect(presenter.present).to eq('We are sorry, thanks but no thanks.')
      end
    end
  end
end
