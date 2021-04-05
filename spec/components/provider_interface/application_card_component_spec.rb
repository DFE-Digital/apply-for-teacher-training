require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationCardComponent do
  include CourseOptionHelpers

  let(:current_provider) do
    create(
      :provider,
      :with_signed_agreement,
      code: 'ABC',
      name: 'Hoth Teacher Training',
    )
  end

  let(:accredited_provider) do
    create(
      :provider,
      :with_signed_agreement,
      code: 'XYZ',
      name: 'Yavin University',
    )
  end

  let(:course_option) do
    course_option_for_provider(
      provider: current_provider,
      course: create(
        :course,
        name: 'Alchemy',
        provider: current_provider,
        accredited_provider: accredited_provider,
      ),
    )
  end

  let(:application_choice) do
    create(
      :application_choice,
      :awaiting_provider_decision,
      course_option: course_option,
      status: 'withdrawn',
      application_form: create(
        :application_form,
        first_name: 'Jim',
        last_name: 'James',
      ),
      site: create(:site, code: 'L123', name: 'Skywalker Training'),
      updated_at: Date.parse('25-03-2020'),
    )
  end

  let(:result) { render_inline described_class.new(application_choice: application_choice) }

  let(:card) { result.css('.app-application-card').to_html }

  describe 'rendering' do
    it 'renders the name of the candidate' do
      expect(card).to include('Jim James')
    end

    it 'renders the name of education provider' do
      expect(card).to include('Hoth Teacher Training')
    end

    it 'renders the name of the course' do
      expect(card).to include('Alchemy')
    end

    it 'renders the name of the accredited provider' do
      expect(card).to include('Yavin University')
    end

    it 'renders the status of the application' do
      expect(card).to include('Application withdrawn')
    end

    it 'renders the recruitment cycle' do
      current_year = RecruitmentCycle.current_year
      expect(card).to include("#{current_year - 1} to #{current_year}")
    end

    it 'renders the location of the course' do
      expect(card).to include('Skywalker Training (L123)')
    end

    context 'when there is no accredited provider' do
      let(:course_option_without_accredited_provider) do
        course_option_for_provider(
          provider: current_provider,
          course: create(
            :course,
            name: 'Baking',
            provider: current_provider,
          ),
        )
      end

      let(:application_choice_without_accredited_provider) do
        create(
          :application_choice,
          :awaiting_provider_decision,
          course_option: course_option_without_accredited_provider,
          status: 'withdrawn',
          application_form: create(
            :application_form,
            first_name: 'Jim',
            last_name: 'James',
          ),
          updated_at: Date.parse('25-03-2020'),
        )
      end

      let(:result) { render_inline described_class.new(application_choice: application_choice_without_accredited_provider) }

      it 'renders the course provider name instead' do
        expect(result.css('[data-qa="provider"]').text).to include('Hoth Teacher Training')
      end
    end
  end

  describe '#days_to_respond_text' do
    around do |example|
      Timecop.freeze { example.run }
    end

    let(:application_choice) do
      create(
        :application_choice,
        :awaiting_provider_decision,
      )
    end

    before { application_choice.reject_by_default_at = rbd }

    subject(:days_to_respond_text) do
      described_class.new(application_choice: application_choice).days_to_respond_text
    end

    context 'when application status is not awaiting_provider_decision' do
      let(:rbd) { Time.zone.now }

      before { application_choice.status = 'offer' }

      it { is_expected.to be_nil }
    end

    context 'when reject_by_default_at is in the past' do
      let(:rbd) { 1.day.ago }

      it { is_expected.to be_nil }
    end

    context 'when less than a day is left to respond' do
      let(:rbd) { 1.hour.from_now }

      it { is_expected.to eq('Last day to make decision') }
    end

    context 'when 1 day is left to respond' do
      let(:rbd) { 1.day.from_now }

      it { is_expected.to eq('1 day to make decision') }
    end

    context 'when 2 days are left to respond' do
      let(:rbd) { 2.days.from_now }

      it { is_expected.to eq('2 days to make decision') }
    end
  end

  describe '#decision_by_date_text' do
    around do |example|
      Timecop.freeze(Time.zone.local(2020, 6, 1, 12, 30, 0)) { example.run }
    end

    let(:application_choice) do
      create(
        :application_choice,
        :with_offer,
        decline_by_default_at: dbd,
      )
    end

    before { application_choice.decline_by_default_at = dbd }

    subject(:candidate_days_to_respond_text) do
      described_class.new(application_choice: application_choice).candidate_days_to_respond_text
    end

    context 'when decision_by_date is in the past' do
      let(:dbd) { Time.zone.parse('2020-05-02T09:05:00+01:00') }

      it { is_expected.to be_nil }
    end

    context 'when less than a day is left to respond' do
      let(:dbd) { Time.zone.parse('2020-06-02T09:05:00+01:00') }

      it { is_expected.to eq('Last day for candidate to respond') }
    end

    context 'when 1 day is left to respond' do
      let(:dbd) { Time.zone.parse('2020-06-03T09:05:00+01:00') }

      it { is_expected.to eq('1 day for candidate to respond') }
    end

    context 'when 2 days are left to respond' do
      let(:dbd) { Time.zone.parse('2020-06-04T09:05:00+01:00') }

      it { is_expected.to eq('2 days for candidate to respond') }
    end
  end

  describe '#recruitment_cycle_text' do
    around do |example|
      Timecop.freeze { example.run }
    end

    let(:current_year) { RecruitmentCycle.current_year }

    let(:course_option) { create(:course_option) }

    let(:application_choice) do
      build_stubbed(
        :application_choice,
        :awaiting_provider_decision,
        course_option: course_option,
      )
    end

    subject(:recruitment_cycle_text) { described_class.new(application_choice: application_choice).recruitment_cycle_text }

    context 'for current year' do
      let(:course_option) { create(:course_option) }

      it { is_expected.to eq("Current cycle (#{current_year - 1} to #{current_year})") }
    end

    context 'for previous year' do
      let(:course_option) { create(:course_option, :previous_year) }

      it { is_expected.to eq("Previous cycle (#{current_year - 2} to #{current_year - 1})") }
    end

    context 'for any other year' do
      let(:course_option) do
        course = create(:course, :open_on_apply, recruitment_cycle_year: RecruitmentCycle.previous_year - 1)
        create(:course_option, course: course)
      end

      it { is_expected.to eq("#{current_year - 3} to #{current_year - 2}") }
    end
  end
end
