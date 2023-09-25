require 'rails_helper'

RSpec.describe UpdateOutOfDateProviderIdsOnApplicationChoices, :sidekiq, :with_audited do
  describe '#perform' do
    let(:wrong_provider) { create(:provider) }
    let(:accredited_course) { create(:course, :with_accredited_provider) }
    let(:accredited_course_option) { create(:course_option, course: accredited_course) }
    let!(:application_choice) do
      create(:application_choice, course_option: accredited_course_option)
    end

    context 'when application choice provider ids are up to date' do
      it 'does nothing if no application choices provider ids are out of date' do
        expect { described_class.new.perform }.not_to change(application_choice, :provider_ids)
      end
    end

    context 'when application choice in current cycle provider ids are out of date', :mid_cycle do
      before { application_choice.update!(provider_ids: [wrong_provider.id]) }

      it 'updates application provider ids' do
        expect { described_class.new.perform }
          .to change { application_choice.reload.provider_ids }
          .from([wrong_provider.id])
          .to([accredited_course.provider.id, accredited_course.accredited_provider.id])
      end

      it 'amends updated_at timestamp on the application' do
        updated_at_time = 1.day.from_now.change(usec: 0)

        travel_temporarily_to(updated_at_time) do
          expect { described_class.new.perform }.to change { application_choice.reload.updated_at }.to(updated_at_time)
        end
      end

      it 'adds an audit comment to application choice' do
        described_class.new.perform
        audit = application_choice.audits.last

        expect(audit.comment)
          .to eq('Update out of date providers on application choice due to provider change')
      end
    end

    context 'when application choice in previous cycle provider ids are out of date' do
      let(:accredited_course) { create(:course, :with_accredited_provider, :previous_year) }

      before { application_choice.update!(provider_ids: [wrong_provider.id]) }

      it 'updates application provider ids' do
        expect { described_class.new.perform }
          .to change { application_choice.reload.provider_ids }
          .from([wrong_provider.id])
          .to([accredited_course.provider.id, accredited_course.accredited_provider.id])
      end

      it 'does not amend updated_at timestamp on the application' do
        updated_at_time = 1.day.before
        application_choice.update!(updated_at: updated_at_time)

        described_class.new.perform

        expect(application_choice.reload.updated_at).to be_within(1.second).of(updated_at_time)
      end
    end
  end
end
