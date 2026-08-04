require 'rails_helper'

RSpec.describe CandidateInterface::InlineApplicationChoiceButtonsComponent do
  include Rails.application.routes.url_helpers

  let(:application_form) { create(:application_form) }
  let(:component) { described_class.new(application_form:) }
  let(:rendered_component) { render_inline(component) }

  describe 'delegations' do
    subject(:a_component) { component }

    it { is_expected.to delegate_method(:can_add_more_choices?).to(:application_form) }
  end

  describe '.application_choices_count' do
    context 'when the application form is submitted' do
      let(:application_form) { create(:application_form, :submitted) }

      it 'returns 2' do
        expect(component.application_choices_count).to eq(2)
      end
    end

    context 'when the application form is not submitted' do
      before { create_list(:application_choice, 3, :unsubmitted, application_form:) }

      it 'return the number of application choices' do
        expect(component.application_choices_count).to eq(3)
      end
    end
  end

  describe '.application_choice_link' do
    context 'when the application form is submitted' do
      let(:application_form) { create(:application_form, :submitted) }

      before { create(:application_choice, :awaiting_provider_decision, application_form:) }

      it 'returns the application choice index link' do
        expect(rendered_component).to have_link('Review your applications', href: candidate_interface_application_choices_path)
      end
    end

    context 'when the application form is unsubmitted' do
      context 'when the application form has one draft application choice' do
        let(:application_choice) { create(:application_choice, :unsubmitted, application_form:) }

        before { application_choice }

        it 'returns a link to review the application choice' do
          expect(rendered_component).to have_link(
            'Review your application',
            href: candidate_interface_course_choices_course_review_path(application_choice.id),
          )
        end
      end

      context 'when the application form has one offered application choice' do
        let(:application_choice) { create(:application_choice, :offer, application_form:) }

        before { application_choice }

        it 'returns a link to review the application choice' do
          expect(rendered_component).to have_link(
            'Review your application',
            href: candidate_interface_offer_path(application_choice.id),
          )
        end
      end

      context 'when the application form has multiple draft application choices' do
        before { create_list(:application_choice, 2, :unsubmitted, application_form:) }

        it 'returns the application choice index link' do
          expect(rendered_component).to have_link('Review your applications', href: candidate_interface_application_choices_path)
        end
      end
    end
  end

  describe 'render' do
    context 'when the application has no application choices' do
      it 'renders a link to choose a course' do
        expect(rendered_component).to have_link('Choose a course', href: candidate_interface_course_choices_do_you_know_the_course_path)
      end
    end

    context 'when the application has one draft application choice' do
      let(:application_choice) { create(:application_choice, :unsubmitted, application_form:) }

      before { application_choice }

      it 'renders a link to review the application choice and a link to apply for a different course' do
        expect(rendered_component).to have_link(
          'Review your application',
          href: candidate_interface_course_choices_course_review_path(application_choice.id),
        )
        expect(rendered_component).to have_link(
          'apply to a different course',
          href: candidate_interface_course_choices_do_you_know_the_course_path,
        )
      end
    end

    context 'when the application has many draft application choices' do
      before { create_list(:application_choice, 2, :unsubmitted, application_form:) }

      it 'renders a link to review the application choices and a link to apply for a different course' do
        expect(rendered_component).to have_link(
          'Review your applications',
          href: candidate_interface_application_choices_path,
        )
        expect(rendered_component).to have_link(
          'apply to a different course',
          href: candidate_interface_course_choices_do_you_know_the_course_path,
        )
      end
    end

    context 'when the application has the maximum number of draft application choices' do
      before { create_list(:application_choice, 4, :unsubmitted, application_form:) }

      it 'renders a link to review the application choices and not a link to apply for a different course' do
        expect(rendered_component).to have_link(
          'Review your applications',
          href: candidate_interface_application_choices_path,
        )
        expect(rendered_component).to have_no_link(
          'apply to a different course',
          href: candidate_interface_course_choices_do_you_know_the_course_path,
        )
      end
    end
  end
end
