require 'rails_helper'

RSpec.describe CandidateInterface::ApplyAgainBannerComponent do
  let(:application_form) { create(:completed_application_form) }

  context 'when all course choices have been cancelled' do
    it 'renders component with correct values' do
      create(:application_choice, application_form: application_form, status: 'cancelled')
      create(:application_choice, application_form: application_form, status: 'cancelled')
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Your application has been withdrawn. Do you want to apply again?')
      expect(result.css('a')[0].attr('href')).to include(Rails.application.routes.url_helpers.candidate_interface_start_apply_again_path)
      expect(result.text).not_to include('The deadline when applying again is')
    end
  end

  context 'when some course choices were not cancelled' do
    it 'renders component with correct values' do
      create(:application_choice, application_form: application_form, status: 'cancelled')
      create(:application_choice, :with_rejection, application_form: application_form)
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Do you want to apply again?')
      expect(result.css('a')[0].attr('href')).to include(Rails.application.routes.url_helpers.candidate_interface_start_apply_again_path)
      expect(result.text).not_to include('Your application has been withdrawn.')
      expect(result.text).not_to include('The deadline when applying again is')
    end
  end

  context 'when application is for an earlier cycle' do
    it 'renders component with correct values' do
      application_choice = create(:application_choice, :with_rejection, application_form: application_form)
      application_choice.course.update(recruitment_cycle_year: RecruitmentCycle.previous_year)

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Do you want to apply again?')
      expect(result.css('a')[0].attr('href')).to include(Rails.application.routes.url_helpers.candidate_interface_start_carry_over_path)
      expect(result.text).not_to include('Your application has been withdrawn.')
      expect(result.text).not_to include('The deadline when applying again is')
    end
  end

  describe 'deadline copy' do
    before do
      # Set required conditions to display deadline copy
      FeatureFlag.activate(:deadline_notices)
      allow(EndOfCycleTimetable).to receive(:show_apply_2_deadline_banner?).and_return true
    end

    it 'is displayed when conditions are met' do
      create(:application_choice, application_form: application_form, status: 'cancelled')
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include 'The deadline when applying again is'
    end

    it 'is not displayed when the feature flag is off' do
      FeatureFlag.deactivate(:deadline_notices)

      create(:application_choice, application_form: application_form, status: 'cancelled')
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).not_to include 'The deadline when applying again is'
    end

    it 'is not displayed when it\'s not the right time' do
      allow(EndOfCycleTimetable).to receive(:show_apply_2_deadline_banner?).and_return false

      create(:application_choice, application_form: application_form, status: 'cancelled')
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).not_to include 'The deadline when applying again is'
    end
  end

  describe 'visibility of banner between cycles' do
    it 'is rendered' do
      Timecop.freeze(Time.zone.local(2020, 9, 17, 12, 0, 0)) do
        result = render_inline(described_class.new(application_form: application_form))
        expect(result.text).to include('Do you want to apply again?')
      end
    end

    it 'is not rendered' do
      Timecop.freeze(Time.zone.local(2020, 9, 25, 12, 0, 0)) do
        result = render_inline(described_class.new(application_form: application_form))
        expect(result.text).to eq('')
      end
    end
  end
end
