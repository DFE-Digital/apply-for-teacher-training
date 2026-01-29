require 'rails_helper'

RSpec.describe CandidateInterface::AfterDeadlineContentComponent do
  describe 'delegations' do
    subject(:component) { described_class.new(application_form:) }

    let(:application_form) { create(:application_form) }

    it { is_expected.to delegate_method(:decline_by_default_at).to(:timetable) }
    it { is_expected.to delegate_method(:after_apply_deadline?).to(:timetable) }

    it { is_expected.to delegate_method(:after_find_opens?).to(:application_form).with_prefix }
    it { is_expected.to delegate_method(:current_recruitment_cycle?).to(:application_form).with_prefix }
    it { is_expected.to delegate_method(:academic_year_range_name).to(:application_form).with_prefix }
    it { is_expected.to delegate_method(:can_submit_more_choices?).to(:application_form).with_prefix }

    it { is_expected.to delegate_method(:before_apply_opens?).to(:next_timetable) }
    it { is_expected.to delegate_method(:before_find_opens?).to(:next_timetable) }
    it { is_expected.to delegate_method(:find_opens_at).to(:next_timetable) }
    it { is_expected.to delegate_method(:apply_opens_at).to(:next_timetable) }
  end

  context 'carried over' do
    context 'before find opens' do
      it 'shows text about carrying over' do
        application_form = create(:application_form)
        travel_temporarily_to(application_form.find_opens_at - 1.day) do
          component = render_inline(described_class.new(application_form:))

          year_range = application_form.academic_year_range_name
          expect(component).to have_text "Apply to courses in the #{year_range} academic year"
          expect(component).not_to have_link('Choose a course', class: 'govuk-button')

          expect(component).to have_text "You will be able to view courses on Find teacher training courses from #{application_form.find_opens_at.to_fs(:govuk_date_time_time_first)}."
          expect(component).to have_text "You can apply for courses from #{application_form.apply_opens_at.to_fs(:govuk_date_time_time_first)}."
        end
      end
    end
    
    context 'after find opens' do
      it 'shows text about carrying over' do
        application_form = create(:application_form)
        travel_temporarily_to(application_form.find_opens_at + 1.day) do
          component = render_inline(described_class.new(application_form:))

          year_range = application_form.academic_year_range_name
          expect(component).to have_text "Apply to courses in the #{year_range} academic year"
          expect(component).to have_link('Choose a course', class: 'govuk-button')

          expect(component).to have_text "You can view courses on Find teacher training courses."
          expect(component).to have_text "You can apply for courses from #{application_form.apply_opens_at.to_fs(:govuk_date_time_time_first)}."
        end
      end
    end
  end

  context 'cannot carry over' do
    it 'does not show choose a course button' do
      application_form = create(
        :application_form,
        :submitted,
        application_choices: [build(:application_choice, :offered)],
      )
      travel_temporarily_to(application_form.decline_by_default_at - 1.day) do
        component = render_inline(described_class.new(application_form:))
        expect(component).to have_no_link('Choose a course', class: 'govuk-button')

        next_year_range = next_timetable.academic_year_range_name
        expect(component).to have_text "Apply to courses in the #{next_year_range} academic year"
      end
    end
  end

  context 'has awaiting provider decision before reject by default at' do
    it 'shows reject by default warning text' do
      application_form = create(
        :application_form,
        :submitted,
        application_choices: [build(:application_choice, :awaiting_provider_decision)],
      )

      travel_temporarily_to(application_form.reject_by_default_at - 1.day) do
        component = render_inline(described_class.new(application_form:))
        expect(component).to have_no_link('Choose a course', class: 'govuk-button')
        expect(component).to have_text application_form.reject_by_default_at.to_fs(:govuk_date_and_time)
        expect(component).to have_text(
          'Applications that are awaiting provider decision or interviewing will be rejected automatically.',
        )
      end
    end
  end

  context 'application has been rejected by default' do
    it 'shows reject by default explanation' do
      application_form = create(
        :application_form,
        :submitted,
        application_choices: [build(:application_choice, :rejected_by_default)],
      )
      travel_temporarily_to(application_form.reject_by_default_at + 1.day) do
        component = render_inline(described_class.new(application_form:))
        expect(component).to have_no_link('Choose a course', class: 'govuk-button')
        expect(component).to have_text(
          "Some of your applications have been rejected automatically. This is because training providers did not respond to them before the deadline of #{application_form.reject_by_default_at.to_fs(:govuk_date_time_time_first)}",
        )
      end
    end
  end

  context 'has offers and it is before decline by default at' do
    it 'shows the decline by default warning' do
      application_form = create(
        :application_form,
        :submitted,
        application_choices: [build(:application_choice, :offer)],
      )
      travel_temporarily_to(application_form.decline_by_default_at - 1.day) do
        component = render_inline(described_class.new(application_form:))
        expect(component).to have_no_link('Choose a course', class: 'govuk-button')
        expect(component).to have_text(application_form.decline_by_default_at.to_fs(:govuk_date_and_time))
        expect(component).to have_text(
          'You must respond to your offers before this time. They will be declined on your behalf if you don’t.',
        )
      end
    end
  end

  context 'an application has been declined by default' do
    it 'shows the decline by default explanation' do
      application_form = create(
        :application_form,
        :submitted,
        application_choices: [build(:application_choice, :declined_by_default)],
      )
      travel_temporarily_to(application_form.decline_by_default_at + 1.minute) do
        component = render_inline(described_class.new(application_form:))
        expect(component).to have_no_link('Choose a course', class: 'govuk-button')
        expect(component).to have_text(
          "Any offers that you had received have been declined on your behalf because you did not respond before the deadline of #{application_form.decline_by_default_at.to_fs(:govuk_date_time_time_first)}. Contact the training provider if you need to discuss this.",
        )
      end
    end
  end

  describe '#academic_year' do
    subject(:academic_year) { described_class.new(application_form:).academic_year }

    context 'when the apply deadline has passed' do
      let(:application_form) { create(:application_form) }

      before do
        allow(application_form).to receive(:after_apply_deadline?).and_return(true)
      end

      it 'returns the applications academic year range name' do
        expect(academic_year).to eq(application_form.academic_year_range_name)
      end
    end

    context 'when the apply deadline has not passed' do
      context 'when the application form has been carried over' do
        let(:application_form) { create(:application_form, :carry_over) }

        it 'returns the previous academic year range name' do
          expect(academic_year).to eq(application_form.previous_application_form.academic_year_range_name)
        end
      end

      context 'when the application form has not been carried over' do
        let(:application_form) { create(:application_form) }

        it 'returns the applications academic year range name' do
          expect(academic_year).to eq(application_form.academic_year_range_name)
        end
      end
    end
  end

  describe '#application_form_start_month_year' do
    subject(:application_form_start_month_year) do
      described_class.new(application_form:).application_form_start_month_year
    end

    context 'when the apply deadline has passed' do
      let(:application_form) { create(:application_form) }

      before do
        allow(application_form).to receive(:after_apply_deadline?).and_return(true)
      end

      it 'returns the applications academic year range name' do
        expect(application_form_start_month_year).to eq(
          application_form.recruitment_cycle_timetable.apply_deadline_at.to_fs(:month_and_year),
        )
      end
    end

    context 'when the apply deadline has not passed' do
      context 'when the application form has been carried over' do
        let(:application_form) { create(:application_form, :carry_over) }

        it 'returns the previous academic year range name' do
          expect(application_form_start_month_year).to eq(
            application_form.previous_application_form
              .recruitment_cycle_timetable
              .apply_deadline_at.to_fs(:month_and_year),
          )
        end
      end

      context 'when the application form has not been carried over' do
        let(:application_form) { create(:application_form) }

        it 'returns the applications academic year range name' do
          expect(application_form_start_month_year).to eq(
            application_form.recruitment_cycle_timetable.apply_deadline_at.to_fs(:month_and_year),
          )
        end
      end
    end
  end

  describe '#show_button?' do
    subject(:show_button) do
      described_class.new(application_form:).show_button?
    end

    let(:application_form) { create(:completed_application_form) }

    it 'returns true' do
      expect(show_button).to be true
    end

    context 'when the application has the maximum number of in progress choices' do
      before do
        create_list(:application_choice, 4, :awaiting_provider_decision, application_form:)
      end

      it 'returns false' do
        expect(show_button).to be false
      end
    end

    context 'when the apply deadline has passed' do
      before do
        allow(
          application_form.recruitment_cycle_timetable,
        ).to receive(:after_apply_deadline?).and_return(true)
      end

      it 'returns false' do
        expect(show_button).to be false
      end
    end

    context 'when find has closed' do
      before do
        allow(application_form).to receive(:after_find_opens?).and_return(false)
      end

      it 'returns false' do
        expect(show_button).to be false
      end
    end
  end
end
