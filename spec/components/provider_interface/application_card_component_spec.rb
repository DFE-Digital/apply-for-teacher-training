require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationCardComponent do
  include CourseOptionHelpers

  let(:current_provider) do
    create(
      :provider,
      code: 'ABC',
      name: 'Hoth Teacher Training',
    )
  end

  let(:accredited_provider) do
    create(
      :provider,
      code: 'XYZ',
      name: 'Yavin University',
    )
  end

  let(:course_option) do
    course_option_for_provider(
      provider: current_provider,
      course:,
      site: create(
        :site,
        code: 'L123',
        name: 'Skywalker Training',
        provider: current_provider,
      ),
      study_mode: 'part_time',
    )
  end

  let(:course) do
    create(
      :course,
      name: 'Alchemy',
      provider: current_provider,
      accredited_provider:,
    )
  end

  let(:application_choice) do
    create(
      :application_choice,
      :awaiting_provider_decision,
      course_option:,
      status: 'withdrawn',
      application_form: create(
        :application_form,
        first_name: 'Jim',
        last_name: 'James',
      ),
      updated_at: Date.parse('25-03-2020'),
    )
  end

  let(:result) { render_inline described_class.new(application_choice:) }

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
      expect(card).to include current_timetable.cycle_range_name
    end

    it 'renders the location of the course' do
      expect(card).to include('Skywalker Training')
    end

    it 'renders the study mode of the course' do
      expect(card).to include('part time at Skywalker Training')
    end

    it 'renders the new location if application choice has been updated' do
      new_course_option = course_option_for_provider(
        provider: current_provider,
        course: create(
          :course,
          name: 'Alchemy',
          provider: current_provider,
          accredited_provider:,
        ),
        site: create(
          :site,
          code: 'L456',
          name: 'Darth Vader Academy',
          provider: current_provider,
        ),
      )
      application_choice.update(current_course_option: new_course_option)

      expect(card).to include('Darth Vader Academy')
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
          updated_at: 2.months.ago,
        )
      end

      let(:result) { render_inline described_class.new(application_choice: application_choice_without_accredited_provider) }

      it 'renders the course provider name instead' do
        expect(result.css('[data-qa="provider"]').text).to include('Hoth Teacher Training')
      end
    end

    context 'when undergraduate' do
      let(:course) do
        create(
          :course,
          :teacher_degree_apprenticeship,
          name: 'Alchemy',
          provider: current_provider,
          accredited_provider:,
        )
      end

      it 'renders undergraduate content' do
        expect(result).to have_text('Undergraduate Jim James', normalize_ws: true)
        expect(result).to have_css(
          'section.app-application-card.app-application-card__undergraduate',
        )
      end
    end

    it 'renders the application number' do
      expect(card).to include(application_choice.id.to_fs)
    end

    it 'does not render undergraduate content' do
      expect(result.text.gsub(/\r?\n/, ' ').squeeze(' ').strip).to match(
        /^Jim James/,
      )
      expect(result).to have_css(
        'section.app-application-card.app-application-card__postgraduate',
      )
    end
  end

  describe '#recruitment_cycle_text' do
    let(:course_option) { create(:course_option) }

    let(:application_choice) do
      build_stubbed(
        :application_choice,
        :awaiting_provider_decision,
        course_option:,
      )
    end

    subject(:recruitment_cycle_text) { described_class.new(application_choice:).recruitment_cycle_text }

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
        course = create(:course, :open, recruitment_cycle_year: previous_year - 1)
        create(:course_option, course:)
      end

      it { is_expected.to eq("#{current_year - 3} to #{current_year - 2}") }
    end
  end
end
