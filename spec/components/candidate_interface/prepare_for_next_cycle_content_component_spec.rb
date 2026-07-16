require 'rails_helper'

RSpec.describe CandidateInterface::PrepareForNextCycleContentComponent do
  subject(:component) { described_class.new(application_form:) }

  let(:application_form) { create(:application_form) }
  let(:recruitment_cycle_timetable) { application_form.recruitment_cycle_timetable }

  before do
    allow(application_form).to receive(:after_apply_deadline?).and_return(false)
  end

  describe 'delegations' do
    it { is_expected.to delegate_method(:recruitment_cycle_timetable).to(:application_form) }
    it { is_expected.to delegate_method(:after_find_opens?).to(:next_recruitment_cycle) }
    it { is_expected.to delegate_method(:academic_year_range_name).to(:next_recruitment_cycle) }
  end

  describe '#next_recruitment_cycle' do
    subject(:next_recruitment_cycle) { component.next_recruitment_cycle }

    context 'when the apply deadline for the application form has passed' do
      before do
        allow(application_form).to receive(:after_apply_deadline?).and_return(true)
      end

      let(:upcoming_recruitment_cycle) do
        recruitment_cycle_timetable.relative_next_timetable
      end

      it 'returns the next recruitment cycle' do
        expect(next_recruitment_cycle).to eq(upcoming_recruitment_cycle)
      end
    end

    context 'when the apply deadline for the application form has not passed' do
      it 'returns the current recruitment cycle' do
        expect(next_recruitment_cycle).to eq(recruitment_cycle_timetable)
      end
    end
  end

  describe '#find_opens' do
    it 'return the find opens date for the next recruitment cycle' do
      expect(component.find_opens).to eq(
        application_form.find_opens_at.to_fs(:govuk_date_time_time_first),
      )
    end
  end

  describe '#apply_opens' do
    it 'return the apply opens date for the next recruitment cycle' do
      expect(component.apply_opens).to eq(
        application_form.apply_opens_at.to_fs(:govuk_date_time_time_first),
      )
    end
  end

  describe '#show_button?' do
    subject(:show_button) do
      component.show_button?
    end

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
        allow(recruitment_cycle_timetable).to receive(:after_find_opens?).and_return(false)
      end

      it 'returns false' do
        expect(show_button).to be false
      end
    end
  end

  describe '#render' do
    let(:rendered_component) { render_inline(described_class.new(application_form:)) }
    let(:academic_year_range_name) { application_form.academic_year_range_name }
    let(:find_opens) { application_form.find_opens_at.to_fs(:govuk_date_time_time_first) }
    let(:apply_opens) { application_form.apply_opens_at.to_fs(:govuk_date_time_time_first) }

    it 'renders the component with instructions about how to prepare for next cycle' do
      expect(rendered_component).to have_element(
        :h2,
        text: "Courses for the #{academic_year_range_name} academic year",
        class: 'govuk-heading-l',
      )
    end

    context 'when the date is before find opens' do
      before do
        allow(recruitment_cycle_timetable).to receive(:after_find_opens?).and_return(false)
      end

      it 'details when find opens and when you can apply' do
        expect(rendered_component).to have_element(
          :p,
          text: "You will be able to view courses starting in the #{academic_year_range_name} academic year from #{find_opens}.",
          class: 'govuk-body',
        )
        expect(rendered_component).to have_element(
          :p,
          text: "You will be able to apply from #{apply_opens}.",
          class: 'govuk-body',
        )
      end
    end

    context 'when the date is after find opens' do
      before do
        allow(recruitment_cycle_timetable).to receive(:after_find_opens?).and_return(true)
      end

      it 'details that find is open and when you can apply' do
        expect(rendered_component).to have_element(
          :p,
          text: "You can now find teacher training courses starting in the #{academic_year_range_name} academic year.",
          class: 'govuk-body',
        )
        expect(rendered_component).to have_element(
          :p,
          text: "You will be able to apply from #{apply_opens}, but you can start preparing your applications now.",
          class: 'govuk-body',
        )
        expect(rendered_component).to have_element(
          :p,
          text: "Before you can apply again, you'll need to:",
          class: 'govuk-body',
        )
        expect(rendered_component).to have_link('find teacher training courses', href: I18n.t('find_teacher_training.production_url'))
        expect(rendered_component).to have_link('confirm your references are up to date')
        expect(rendered_component).to have_link('enter or confirm your equality and diversity information')
        expect(rendered_component).to have_link('confirm whether you have started teacher training in the past')
      end
    end
  end
end
