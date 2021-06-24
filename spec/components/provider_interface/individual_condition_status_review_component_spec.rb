require 'rails_helper'

RSpec.describe ProviderInterface::IndividualConditionStatusReviewComponent do
  let(:all_conditions_met) { false }
  let(:any_condition_not_met) { false }
  let(:form_object) { double }

  let(:render) { render_inline(described_class.new(form_object: form_object, application_choice: create(:application_choice, :with_offer))) }

  before do
    allow(form_object).to receive(:all_conditions_met?).and_return(all_conditions_met)
    allow(form_object).to receive(:any_condition_not_met?).and_return(any_condition_not_met)
    allow(form_object).to receive(:conditions).and_return([])
  end

  context 'when conditions are not all met or unmet' do
    it 'shows the correct title' do
      expect(render.css('h1').text).to eq('Check and update status of conditions')
    end

    it 'shows the correct button text without the warning class' do
      expect(render.css('input .govuk-button--warning')).to be_empty
      expect(render.css('input[type="submit"]').first['value']).to eq('Update status')
    end
  end

  context 'when all conditions are met' do
    let(:all_conditions_met) { true }

    it 'shows the correct title' do
      expect(render.css('h1').text).to eq('Check your changes and mark conditions as met')
    end

    it 'shows the correct button text without the warning class' do
      expect(render.css('input .govuk-button--warning')).to be_empty
      expect(render.css('input[type="submit"]').first['value']).to eq('Mark conditions as met and tell candidate')
    end
  end

  context 'when a condition is not met' do
    let(:any_condition_not_met) { true }

    it 'shows the correct title' do
      expect(render.css('h1').text).to eq('Check your changes and mark conditions as not met')
    end

    it 'shows the correct button text with the warning class' do
      expect(render.css('.govuk-button--warning').css('input[type="submit"]').first['value']).to eq('Mark conditions as not met')
    end

    it 'shows the information text about the status of the application' do
      expect(render.text).to include('The candidate will be told that their application was unsuccessful.')
    end
  end
end
