require 'rails_helper'

RSpec.describe CandidateInterface::PersonalDetailsReviewComponent do
  let(:application_form) { build_stubbed(:completed_application_form) }

  context 'when personal details are editable' do
    it 'renders SummaryCardComponent with valid personal details' do
      result = render_inline(described_class.new(application_form:))

      expect(result.text).to include(application_form.first_name)
      expect(result.text).to include('Change')
    end

    it 'renders fallback text with invalid personal details' do
      application_form = build_stubbed(:application_form)
      result = render_inline(described_class.new(application_form:))

      expect(result.text).to include('Personal details not marked as complete')
    end
  end

  context 'when personal details are not editable' do
    it 'renders component without an edit link' do
      result = render_inline(described_class.new(application_form:, editable: false))

      expect(result.css('.app-summary-list__actions').text).not_to include('Change')
    end
  end

  context 'when there are no details' do
    it 'renders with links to enter details' do
      result = render_inline(described_class.new(application_form: build(:application_form)))

      expect(page).to have_css('[data-qa="personal-details-name"]')

        expect(result).to have_text('Name')
        expect(result).to have_link('Enter your name', href: candidate_interface_edit_name_and_dob_path)
        expect(result).to have_no_link('Change name', href: candidate_interface_edit_name_and_dob_path)
    end
  end

  context 'when the Candidates name is filled in' do
    it 'renders the Candidates name' do
      result = render_inline(described_class.new(application_form: build(:application_form)))

      expect(result.text).to include('Name')
      expect(result.text).to include('Enter your name')
    end
  end
end
