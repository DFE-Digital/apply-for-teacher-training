require 'rails_helper'

RSpec.describe CandidateInterface::InlineApplicationChoiceButtonsComponent do
  let(:application_form) { create(:application_form) }
  let(:component) { described_class.new(application_form:) }

  describe 'delegations' do
    subject(:a_component) { component }

    it { is_expected.to delegate_method(:can_add_more_choices?).to(:application_form) }
  end

  describe '.application_choices_count' do
    context 'when the application form is submitted' do
      let(:application_form) { create(:application_form, :submitted) }

      it 'returns 2' do
        expect(component.application_choices_count).to eq(2)
      end
    end

    context 'when the application form is not submitted' do
      before { create_list(:application_choice, 3, :unsubmitted, application_form:) }

      it 'return the number of application choices' do
        expect(component.application_choices_count).to eq(3)
      end
    end
  end

  describe '.application_choice_link' do
    context 'when the application form is submitted' do
      let(:application_form) { create(:application_form, :submitted) }

      it '' do

      end
    end
  end
end
