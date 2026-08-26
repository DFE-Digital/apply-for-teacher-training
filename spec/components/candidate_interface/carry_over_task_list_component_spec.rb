require 'rails_helper'

RSpec.describe CandidateInterface::CarryOverTaskListComponent do
  subject(:component) { described_class.new(application_form:) }

  let(:application_form) { create(:application_form) }

  describe 'delegations' do
    it { is_expected.to delegate_method(:previous_application_form).to(:application_form) }
  end

  describe '#render' do
    let(:rendered_component) { render_inline(described_class.new(application_form:)) }

    context 'when a candidate has previously applied and has sections to check' do
      before do
        FeatureFlag.activate('2027_visa_expiry')
      end

      let(:previous_application_form) { create(:application_form, :submitted, efl_completed: true) }
      let(:application_form) do
        create(
          :application_form,
          previous_application_form:,
          first_nationality: 'Indian',
        )
      end

      let!(:previous_teacher_training) do
        create(
          :previous_teacher_training,
          :published,
          application_form: previous_application_form,
        )
      end
      let!(:gcse_qualification) { create(:gcse_qualification, :indian, application_form:) }

      it 'lists all the sections the candidate needs to check' do
        expect(rendered_component).to have_element(
          :p,
          text: 'Before you can apply again, you’ll need to:',
          class: 'govuk-body',
        )

        expect(rendered_component).to have_link('enter or confirm your visa information')
        expect(rendered_component).to have_link('confirm your contact information')
        expect(rendered_component).to have_link('confirm your qualifications are up to date')
        expect(rendered_component).to have_link('enter or confirm your English language skills')
        expect(rendered_component).to have_link('enter or confirm your equality and diversity information')
        expect(rendered_component).to have_link('confirm whether you have started teacher training in the past')
        expect(rendered_component).to have_link('confirm your references are up to date')
      end

      context 'when there are other incomplete sections outside carry over' do
        let(:application_form) do
          create(
            :application_form,
            :minimum_info,
            previous_application_form:,
            first_nationality: 'Indian',
          )
        end

        it 'lists all the sections and shows a message about the other incomplete sections' do
          expect(rendered_component).to have_element(
            :p,
            text: 'Before you can apply again, you’ll need to:',
            class: 'govuk-body',
          )

          expect(rendered_component).to have_link('enter or confirm your visa information')
          expect(rendered_component).to have_link('confirm your contact information')
          expect(rendered_component).to have_link('confirm your qualifications are up to date')
          expect(rendered_component).to have_link('enter or confirm your English language skills')
          expect(rendered_component).to have_link('enter or confirm your equality and diversity information')
          expect(rendered_component).to have_link('confirm whether you have started teacher training in the past')
          expect(rendered_component).to have_link('confirm your references are up to date')
          expect(rendered_component).to have_text(
            'You also have other incomplete sections in your details. You’ll need to complete these before you can apply again',
          )
        end
      end
    end

    context 'when a candidate has not previously applied but has incomplete sections outside carry over' do
      let(:application_form) do
        create(
          :application_form,
          :completed,
          efl_completed: true,
          work_history_completed: false,
          volunteering_completed: false,
        )
      end

      it 'only shows the incomplete details message' do
        expect(rendered_component).to have_text(
          'You will not be able to submit applications until you have completed your details.',
        )
        expect(rendered_component).to have_no_text('Before you can apply again, you’ll need to:')
      end
    end

    context 'when a candidate is british and has not completed the efl or visa section' do
      before do
        FeatureFlag.activate('2027_visa_expiry')
      end

      let(:previous_application_form) { create(:application_form, :submitted, efl_completed: false) }
      let(:application_form) do
        create(
          :application_form,
          :minimum_info,
          previous_application_form:,
          first_nationality: 'British',
        )
      end

      it 'they do not see the efl or visa link' do
        expect(rendered_component).to have_link('confirm your contact information')
        expect(rendered_component).to have_no_link('enter or confirm your visa information')
        expect(rendered_component).to have_no_link('enter or confirm your English language skills')
      end
    end
  end
end
