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

      it 'renders both current cyle and previous cycle associated applications' do
        result = render_inline(described_class.new(application_form:, current_provider_user:))

        expect(result.text).to include('Important')
      end
    end
  end
end
