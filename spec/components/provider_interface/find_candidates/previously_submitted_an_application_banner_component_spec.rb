require 'rails_helper'
RSpec.describe ProviderInterface::FindCandidates::PreviouslySubmittedAnApplicationBannerComponent, type: :component do
  describe '#render?' do
    let(:candidate) { create(:candidate) }
    let(:provider) { create(:provider) }
    let(:application_form) { create(:application_form, :completed, candidate:, submitted_at: 1.day.ago) }
    let(:application_choice) { create(:application_choice, :submitted, provider:, application_form:) }
    let(:current_provider_user) { create(:provider_user, providers: [provider]) }

    context 'when the candidate has associated applications in the current cycle and a previous cycle' do
      let(:last_cycle_application_form) do
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
        create(:application_choice, :submitted, provider:, application_form: form)

        form
      end

      it 'renders both current cyle and previous cycle associated applications' do
        result = render_inline(described_class.new(application_form:, current_provider_user:))

        expect(result.text).to include('Important')
      end
    end
  end
end
