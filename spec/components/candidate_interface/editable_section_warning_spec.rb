require 'rails_helper'

RSpec.describe CandidateInterface::EditableSectionWarning do
  subject(:result) do
    render_inline(
      described_class.new(current_application:, section_policy:),
    )
  end

  context 'when candidate has submitted applications' do
    let(:current_application) { create(:application_form, :completed, submitted_application_choices_count: 1) }

    context 'when candidate can edit the section' do
      let(:section_policy) { instance_double(CandidateInterface::SectionPolicy, can_edit?: true) }

      it 'renders message' do
        expect(result.text).to include(
          'Any changes you make will be included in applications you’ve already submitted.',
        )
      end
    end

    context 'when candidate can not edit the section' do
      let(:section_policy) { instance_double(CandidateInterface::SectionPolicy, can_edit?: false) }

      it 'renders nothing' do
        expect(result.text).to be_blank
      end
    end
  end

  context 'when candidate did not submitted yet' do
    let(:section_policy) { instance_double(CandidateInterface::SectionPolicy, can_edit?: true) }
    let(:current_application) { create(:application_form) }

    it 'renders nothing' do
      expect(result.text).to be_blank
    end
  end
end
