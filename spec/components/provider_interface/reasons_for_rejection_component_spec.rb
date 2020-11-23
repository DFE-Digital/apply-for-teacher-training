require 'rails_helper'

RSpec.describe ProviderInterface::ReasonsForRejectionComponent do
  describe 'rendered component' do
    let(:application_choice) { build_stubbed(:application_choice) }
    let(:reasons_for_rejection_attrs) do
      {
        candidate_behaviour_y_n: 'Yes',
        candidate_behaviour_what_did_the_candidate_do: %w[other],
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
        offered_on_another_course_y_n: 'No',
        honesty_and_professionalism_y_n: 'No',
        safeguarding_y_n: 'No',
        other_advice_or_feedback_y_n: 'Yes',
        other_advice_or_feedback_details: 'That zoom background...',
        interested_in_future_applications_y_n: 'Yes',
      }
    end

    let(:reasons_for_rejection) { ProviderInterface::ReasonsForRejection.new(reasons_for_rejection_attrs) }

    it 'renders rejection reason answers under headings' do
      result = render_inline(described_class.new(application_choice: application_choice, reasons_for_rejection: reasons_for_rejection)).to_html

      expect(result).to include('Something you did')
      expect(result).to include('Shouted a lot')
      expect(result).to include('Speak calmly')

      expect(result).to include('Quality of application')
      expect(result).to include('Do not refer to yourself in the third person')
      expect(result).to include('Write in the first person')

      expect(result).to include('Qualifications')
      expect(result).to include('No English GCSE grade 4 (C) or above, or valid equivalent')
      expect(result).to include('No Science GCSE grade 4 (C) or above, or valid equivalent (for primary applicants)')
      expect(result).to include('No degree')

      expect(result).to include('Performance at interview')
      expect(result).to include('There was no need to do all those pressups')

      expect(result).to include('Additional advice')
      expect(result).to include('That zoom background...')
    end

    it 'renders change links when editable' do
      result = render_inline(described_class.new(application_choice: application_choice, reasons_for_rejection: reasons_for_rejection, editable: true))

      expect(result.css('.app-rejection-change-link').text).to include('Change')
    end
  end
end
