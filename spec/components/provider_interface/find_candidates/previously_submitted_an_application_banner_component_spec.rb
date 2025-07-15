require 'rails_helper'

RSpec.describe ProviderInterface::FindCandidates::PreviouslySubmittedAnApplicationBannerComponent, type: :component do
  describe '#render?' do
    let(:candidate) { create(:candidate) }
    let(:application_form) { create(:application_form, :completed, candidate:, submitted_at: 1.day.ago) }
    let(:provider) { create(:provider) }
    let(:course) { create(:course, provider:) }
    let(:course_option) { create(:course_option, course:) }
    let!(:application_choice) { create(:application_choice, course_option:, application_form:, status: 'awaiting_provider_decision') }
    let(:current_provider_user) { create(:provider_user, providers: [provider]) }

    context 'when the candidate has associated applications in the current cycle and a previous cycle' do
      let!(:last_cycle_application_form) do
        previous_year = CycleTimetableHelper.previous_year
        form = create(
          :application_form,
          :completed,
          recruitment_cycle_year: previous_year,
          submitted_at: CycleTimetableHelper.mid_cycle(previous_year),
          candidate:,
          created_at: CycleTimetableHelper.mid_cycle(previous_year),
          updated_at: CycleTimetableHelper.mid_cycle(previous_year),
        )
        previous_course = create(:course, provider:)
        course_option_2 = create(:course_option, course: previous_course)
        create(:application_choice, course_option: course_option_2, status: 'withdrawn', application_form: form)

        form
      end

      it 'renders both current cycle and previous cycle associated applications' do
        result = render_inline(described_class.new(application_form:, current_provider_user:))

        expect(result.text).to include('Important')
        expect(result.text).to include('This candidate has submitted an application to you or a partner before')
        expect(result.text).to include(course.name_and_code)
        expect(result.text).to include('Received')
        expect(result.text).to include('2023 to 2024 recruitment cycle:')
        expect(result.text).to include(last_cycle_application_form.application_choices.first.course.name_and_code)
        expect(result.text).to include('Application withdrawn')
      end
    end

    context 'when the candidate has associated applications only in a previous cycle' do
      let!(:last_cycle_application_form) do
        previous_year = CycleTimetableHelper.previous_year
        form = create(
          :application_form,
          :completed,
          recruitment_cycle_year: previous_year,
          submitted_at: CycleTimetableHelper.mid_cycle(previous_year),
          candidate:,
          created_at: CycleTimetableHelper.mid_cycle(previous_year),
          updated_at: CycleTimetableHelper.mid_cycle(previous_year),
        )
        previous_course = create(:course, provider:)
        course_option_2 = create(:course_option, course: previous_course)
        create(:application_choice, course_option: course_option_2, status: 'withdrawn', application_form: form)

        form
      end

      before do
        application_choice.destroy!
        application_form.destroy!
      end

      it 'renders only previous cycle associated applications' do
        result = render_inline(described_class.new(application_form: last_cycle_application_form, current_provider_user:))

        expect(result.text).to include('Important')
        expect(result.text).to include('This candidate has submitted an application to you or a partner before')
        expect(result.text).to include('2023 to 2024 recruitment cycle:')
        expect(result.text).to include(last_cycle_application_form.application_choices.first.course.name_and_code)
        expect(result.text).to include('Application withdrawn')
        expect(result.text).not_to include('Received')
      end
    end

    context 'when the candidate has associated applications only in the current cycle' do
      it 'renders only current cycle associated applications' do
        result = render_inline(described_class.new(application_form:, current_provider_user:))

        expect(result.text).to include('Important')
        expect(result.text).to include('This candidate has submitted an application to you or a partner before')
        expect(result.text).to include(course.name_and_code)
        expect(result.text).to include('Received')
        expect(result.text).not_to include('2023 to 2024 recruitment cycle:')
        expect(result.text).not_to include('Application withdrawn')
      end
    end
  end
end
