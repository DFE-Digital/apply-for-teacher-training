require 'rails_helper'

RSpec.describe CandidateInterface::CarryOverBannerComponent do
  include CycleTimetableHelper
  let(:application_form) { build(:completed_application_form) }
  let(:current_recruitment_cycle_year) { RecruitmentCycle.current_year }
  let(:previous_recruitment_cycle_year) { RecruitmentCycle.previous_year }

  context 'after the new recruitment cycle begins' do
    around do |example|
      Timecop.freeze(after_apply_reopens) do
        example.run
      end
    end

    it 'renders nothing when application is recruited and from last recruitment cycle' do
      create(:application_choice, application_form: application_form, status: :recruited)
      application_form.recruitment_cycle_year = previous_recruitment_cycle_year
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to be_blank
    end

    it 'renders component when application is rejected from last recruitment cycle' do
      create(:application_choice, :with_rejection, application_form: application_form)
      application_form.recruitment_cycle_year = previous_recruitment_cycle_year
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Do you want to continue applying?')
      expect(result.text).to include('Continue your application')
      expect(result.css('a')[0].attr('href')).to include(Rails.application.routes.url_helpers.candidate_interface_start_carry_over_path)
    end

    it 'renders component when application is unsubmitted from last recruitment cycle' do
      create(:application_choice, application_form: application_form, status: :unsubmitted)
      application_form.recruitment_cycle_year = previous_recruitment_cycle_year
      application_form.submitted_at = nil
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Do you want to continue applying?')
      expect(result.text).to include('Continue your application')
      expect(result.css('a')[0].attr('href')).to include(Rails.application.routes.url_helpers.candidate_interface_start_carry_over_path)
    end

    it 'renders component when application is unsubmitted and without application choices from last recruitment cycle' do
      application_form.recruitment_cycle_year = previous_recruitment_cycle_year
      application_form.submitted_at = nil
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Do you want to continue applying?')
      expect(result.text).to include('Continue your application')
      expect(result.css('a')[0].attr('href')).to include(Rails.application.routes.url_helpers.candidate_interface_start_carry_over_path)
    end

    it 'renders nothing when application is rejected from the current recruitment cycle' do
      create(:application_choice, :with_rejection, application_form: application_form)
      application_form.recruitment_cycle_year = current_recruitment_cycle_year
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to be_blank
    end
  end

  context 'after the apply 2 deadline has passed' do
    around do |example|
      Timecop.freeze(after_apply_2_deadline) do
        example.run
      end
    end

    it 'renders nothing when application is recruited and from last recruitment cycle' do
      create(:application_choice, application_form: application_form, status: :recruited)
      application_form.recruitment_cycle_year = previous_recruitment_cycle_year
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to be_blank
    end

    it 'renders nothing when application is unsubmitted' do
      create(:application_choice, application_form: application_form, status: :unsubmitted)
      application_form.recruitment_cycle_year = previous_recruitment_cycle_year
      application_form.submitted_at = nil
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to be_blank
    end

    it 'renders nothing when application is unsubmitted and without application choices' do
      application_form.recruitment_cycle_year = previous_recruitment_cycle_year
      application_form.submitted_at = nil
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to be_blank
    end

    it 'renders component when application is rejected from last recruitment cycle' do
      create(:application_choice, :with_rejection, application_form: application_form)
      application_form.recruitment_cycle_year = previous_recruitment_cycle_year
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('a')[0].attr('href')).to include(Rails.application.routes.url_helpers.candidate_interface_start_carry_over_path)
    end

    it 'renders component when application is rejected from the current recruitment cycle' do
      create(:application_choice, :with_rejection, application_form: application_form)
      application_form.recruitment_cycle_year = current_recruitment_cycle_year
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('a')[0].attr('href')).to include(Rails.application.routes.url_helpers.candidate_interface_start_carry_over_path)
    end

    it 'renders component when references did not come back in time' do
      create(:application_choice, :with_rejection, application_form: application_form)
      application_form.application_references << build(:reference, feedback_status: :cancelled_at_end_of_cycle)
      application_form.recruitment_cycle_year = current_recruitment_cycle_year

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Your references did not come back in time')
    end

    it 'renders component when between cycles and rejected' do
      create(:application_choice, :with_rejection, application_form: application_form)
      application_form.recruitment_cycle_year = current_recruitment_cycle_year
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Your application did not lead to a place')
    end
  end
end
