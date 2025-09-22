require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationChoices::IndexContentComponent do
  describe '#content_component' do
    it 'returns UpdateLocationAndFundingPreferencesComponent' do
      application_form = build_stubbed(:application_form)
      allow(application_form).to receive_messages(
        carry_over?: false,
        after_apply_deadline?: false,
        before_apply_opens?: false,
      )

      component = described_class.new(application_form:)

      expect(component.content_component).to be_a(CandidateInterface::MidCycleContentComponent)
    end

    context 'when the application form can be carried over and we are midcycle' do
      it 'returns CarryOverMidCycleComponent' do
        application_form = create(:application_form)
        next_cycle_opens_at = application_form.recruitment_cycle_timetable.relative_next_timetable.apply_opens_at
        travel_temporarily_to(next_cycle_opens_at + 1.hour) do
          component = described_class.new(application_form:)

          expect(component.content_component).to be_a(CandidateInterface::CarryOverMidCycleComponent)
        end
      end
    end

    context 'when the application form can be carried over and it is currently between cycles' do
      it 'returns AfterDeadlineContentComponent' do
        application_form = create(:application_form)
        travel_temporarily_to(application_form.apply_deadline_at + 1.hour) do
          component = described_class.new(application_form:)

          expect(component.content_component).to be_a(CandidateInterface::AfterDeadlineContentComponent)
        end
      end
    end

    context 'when the application form is after the apply deadline' do
      it 'returns AfterDeadlineContentComponent' do
        application_form = build_stubbed(:application_form)
        allow(application_form).to receive_messages(
          carry_over?: false,
          after_apply_deadline?: true,
          before_apply_opens?: false,
        )

        travel_temporarily_to(application_form.decline_by_default_at + 2.days) do
          component = described_class.new(application_form:)
          render_inline(component)

          expect(component.content_component).to be_a(CandidateInterface::AfterDeadlineContentComponent)
          expect(rendered_content).not_to include("You have until #{application_form.decline_by_default_at.to_fs(:govuk_date_time_time_first)} to respond to your offers. After this time they will be rejected.")
        end
      end
    end

    context 'when the application form is after the apply deadline and before the decline by default date' do
      it 'the AfterDeadlineContentComponent includes the decline by default reminder content' do
        application_form = create(:application_form)
        create(:application_choice, :offered, application_form:)

        travel_temporarily_to(application_form.decline_by_default_at - 2.days) do
          component = described_class.new(application_form:)

          render_inline(component)

          expect(component.content_component).to be_a(CandidateInterface::AfterDeadlineContentComponent)
          expect(rendered_content).to include('You must respond to your offers before this time. They will be declined on your behalf if you don’t.')
        end
      end
    end

    context 'when the application form is before apply opens, not after the apply deadline' do
      it 'returns CarriedOverContentComponent' do
        application_form = create(:application_form)
        travel_temporarily_to(application_form.find_opens_at + 1.minute) do
          component = described_class.new(application_form:)

          expect(component.content_component).to be_a(CandidateInterface::CarriedOverContentComponent)
        end
      end
    end
  end
end
