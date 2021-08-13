require 'rails_helper'

RSpec.describe ReasonsForRejectionComponent do
  describe 'rendered component' do
    let(:provider) { build_stubbed(:provider, name: 'The University of Metal') }
    let(:course) { build_stubbed(:course, provider: provider) }
    let(:application_choice) { build_stubbed(:application_choice) }
    let(:future_applications) { 'Yes' }
    let(:reasons_for_rejection_attrs) do
      {
        candidate_behaviour_y_n: 'Yes',
        candidate_behaviour_what_did_the_candidate_do: %w[other didnt_reply_to_interview_offer],
        candidate_behaviour_other: 'Shouted a lot',
        candidate_behaviour_what_to_improve: 'Speak calmly',
        quality_of_application_y_n: 'Yes',
        quality_of_application_which_parts_needed_improvement: %w[personal_statement subject_knowledge],
        quality_of_application_personal_statement_what_to_improve: 'Do not refer to yourself in the third person',
        quality_of_application_subject_knowledge_what_to_improve: 'Write in the first person',
        qualifications_y_n: 'Yes',
        qualifications_which_qualifications: %w[no_english_gcse no_science_gcse no_degree],
        performance_at_interview_y_n: 'Yes',
        performance_at_interview_what_to_improve: 'There was no need to do all those pressups',
        course_full_y_n: 'No',
        offered_on_another_course_y_n: 'Yes',
        offered_on_another_course_details: 'We felt you would be better suited to Mathematics',
        honesty_and_professionalism_y_n: 'No',
        safeguarding_y_n: 'No',
        cannot_sponsor_visa_y_n: 'No',
        other_advice_or_feedback_y_n: 'Yes',
        other_advice_or_feedback_details: 'That zoom background...',
        interested_in_future_applications_y_n: future_applications,
      }
    end

    let(:reasons_for_rejection) { ReasonsForRejection.new(reasons_for_rejection_attrs) }

    before do
      allow(application_choice).to receive(:provider).and_return(provider)
      allow(application_choice).to receive(:course).and_return(course)
    end

    it 'renders rejection reason answers under headings' do
      result = render_inline(described_class.new(application_choice: application_choice, reasons_for_rejection: reasons_for_rejection))
      html = result.to_html

      expect(result.css('h3.govuk-heading-s').text).to include('Something you did')
      expect(html).to include('Didn’t reply to our interview offer')
      expect(html).to include('Shouted a lot')
      expect(html).to include('Speak calmly')

      expect(result.css('h3.govuk-heading-s').text).to include('Quality of application')
      expect(html).to include('Do not refer to yourself in the third person')
      expect(html).to include('Write in the first person')

      expect(result.css('h3.govuk-heading-s').text).to include('Qualifications')
      expect(html).to include('No English GCSE grade 4 (C) or above, or valid equivalent')
      expect(html).to include('No Science GCSE grade 4 (C) or above, or valid equivalent (for primary applicants)')
      expect(html).to include('No degree')
      expect(html).not_to include("https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{application_choice.provider.code}/#{application_choice.course_option.course.code}#section-entry")

      expect(result.css('h3.govuk-heading-s').text).to include('Performance at interview')
      expect(html).to include('There was no need to do all those pressups')

      expect(result.css('h3.govuk-heading-s').text).to include('They offered you a place on another course')
      expect(html).to include('We felt you would be better suited to Mathematics')

      expect(result.css('h3.govuk-heading-s').text).to include('Additional feedback')
      expect(html).to include('That zoom background...')

      expect(result.css('h3.govuk-heading-s').text).to include('Future applications')
      expect(html).to include('The University of Metal would be interested in future applications from you.')
    end

    it 'renders link to course requirements when rejected on qualifications is true' do
      result = render_inline(described_class.new(application_choice: application_choice, reasons_for_rejection: reasons_for_rejection, render_link_to_find_when_rejected_on_qualifications: true))
      html = result.to_html

      expect(result.css('h3.govuk-heading-s').text).to include('Qualifications')
      expect(html).to include('No English GCSE grade 4 (C) or above, or valid equivalent')
      expect(html).to include('No Science GCSE grade 4 (C) or above, or valid equivalent (for primary applicants)')
      expect(html).to include('No degree')
      expect(html).to include("https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{application_choice.provider.code}/#{application_choice.course.code}#section-entry")
    end

    it 'renders change links when editable' do
      result = render_inline(described_class.new(application_choice: application_choice, reasons_for_rejection: reasons_for_rejection, editable: true))

      expect(result.css('.app-rejection__actions').text).to include('Change')
    end

    it 'renders subheadings as h2s when editable' do
      result = render_inline(described_class.new(application_choice: application_choice, reasons_for_rejection: reasons_for_rejection, editable: true))
      expect(result.css('h2.govuk-heading-s').text).to include('Something you did')
      expect(result.css('h2.govuk-heading-s').text).to include('Quality of application')
      expect(result.css('h2.govuk-heading-s').text).to include('Qualifications')
      expect(result.css('h2.govuk-heading-s').text).to include('Performance at interview')
      expect(result.css('h2.govuk-heading-s').text).to include('Additional feedback')
      expect(result.css('h2.govuk-heading-s').text).to include('Future applications')
    end

    context 'when future applications question is not given' do
      let(:future_applications) { nil }

      it 'does not render the answer' do
        result = render_inline(described_class.new(application_choice: application_choice, reasons_for_rejection: reasons_for_rejection))

        expect(result.css('h3.govuk-heading-s').text).not_to include('Future applications')
      end
    end
  end
end
