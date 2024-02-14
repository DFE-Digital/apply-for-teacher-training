require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::ApplicationChoiceListComponent do
  let(:application_form) { create(:application_form) }
  let(:application_choices) do
    CandidateInterface::SortApplicationChoices.call(application_choices: application_form.application_choices)
  end
  let(:application_choice_list_component) do
    described_class.new(application_form:, application_choices:)
  end
  let(:current_tab_name) do
    result.css('nav.tabs-component li a').find { |tab| tab['aria-current'] == 'page' }&.text
  end

  subject(:result) do
    render_inline(application_choice_list_component)
  end

  context 'when candidate has application choices in all categories' do
    before do
      create(:application_choice, :offer_withdrawn, application_form:)
      create(:application_choice, :withdrawn, application_form:)
      create(:application_choice, :declined, application_form:)
      create(:application_choice, :awaiting_provider_decision, application_form:)
      create(:application_choice, :inactive, application_form:)
      create(:application_choice, :interviewing, application_form:)
      create(:application_choice, :rejected, application_form:)
      create(:application_choice, :conditions_not_met, application_form:)
      create(:application_choice, :unsubmitted, application_form:)
      create(:application_choice, :application_not_sent, application_form:)
      create(:application_choice, :cancelled, application_form:)
      create(:application_choice, :offer, application_form:)
    end

    it 'sort group headers in the expected order' do
      expect(result.css('nav.tabs-component li a').map(&:text)).to eq([
        'All applications',
        'Offers received',
        'Draft',
        'Unsuccessful',
        'In progress',
        'Withdraw',
        'Declined',
      ])
    end

    it 'renders all applications' do
      expect(application_choices).not_to be_empty

      application_choices.each do |application_choice|
        expect(
          result.css('.app-application-item a').map(&:text).join(' '),
        ).to include(application_choice.course.provider.name)
      end
    end
  end

  context 'when only some application choice groups' do
    before do
      create(:application_choice, :awaiting_provider_decision, application_form:)
      create(:application_choice, :inactive, application_form:)
      create(:application_choice, :interviewing, application_form:)
      create(:application_choice, :rejected, application_form:)
      create(:application_choice, :conditions_not_met, application_form:)
      create(:application_choice, :unsubmitted, application_form:)
      create(:application_choice, :application_not_sent, application_form:)
      create(:application_choice, :cancelled, application_form:)
      create(:application_choice, :offer, application_form:)
    end

    it 'sort group headers in the expected order' do
      expect(result.css('nav.tabs-component li a').map(&:text)).to eq([
        'All applications',
        'Offers received',
        'Draft',
        'Unsuccessful',
        'In progress',
      ])
    end

    it 'renders all applications' do
      expect(application_choices).not_to be_empty

      application_choices.each do |application_choice|
        expect(
          result.css('.app-application-item a').map(&:text).join(' '),
        ).to include(application_choice.course.provider.name)
      end
    end
  end

  %w[offers_received draft unsuccessful in_progress withdraw declined].each do |tab|
    context "when passing #{tab} as current tab" do
      let(:application_choice_list_component) do
        described_class.new(application_form:, application_choices:, current_tab_name: tab)
      end

      before do
        create(:application_choice, :offer, application_form:)
        create(:application_choice, :unsubmitted, application_form:)
        create(:application_choice, :rejected, application_form:)
        create(:application_choice, :awaiting_provider_decision, application_form:)
        create(:application_choice, :offer_withdrawn, application_form:)
        create(:application_choice, :declined, application_form:)
      end

      it "sets #{tab} as current tab" do
        expect(current_tab_name).to eq(I18n.t("candidate_interface.application_tabs.#{tab}"))
      end

      it "shows only the applications related to #{tab}" do
        expect(
          result.css('.app-application-item').size,
        ).to be 1
      end
    end
  end

  [nil, 'foo'].each do |tab|
    context 'when passing an non existent tab' do
      let(:application_choice_list_component) do
        described_class.new(application_form:, application_choices:, current_tab_name: tab)
      end

      before do
        create(:application_choice, :offer, application_form:)
        create(:application_choice, :unsubmitted, application_form:)
        create(:application_choice, :rejected, application_form:)
        create(:application_choice, :awaiting_provider_decision, application_form:)
        create(:application_choice, :offer_withdrawn, application_form:)
        create(:application_choice, :declined, application_form:)
      end

      it 'sets all applications as current tab' do
        expect(current_tab_name).to eq('All applications')
      end
    end
  end

  context 'when no application choices' do
    let(:application_choices) { [] }

    it 'renders nothing' do
      expect(result.text).to be_blank
    end
  end
end
