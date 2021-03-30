require 'rails_helper'

RSpec.describe CandidateInterface::PreviousApplicationsComponent do
  let(:candidate) { create(:candidate) }

  describe 'a current application ' do
    context 'with a single application choice with an ACCEPTED state' do
      let(:current_application_form) { create_application_form_with_course_choices(statuses: [status], candidate: candidate) }

      ApplicationStateChange::ACCEPTED_STATES.each do |status|
        let(:status) { status }

        it "does not render the component for accepted state: '#{status}'" do
          result = render_inline(described_class.new(candidate: candidate))

          expect(result.css('.govuk-table__caption--m').text).to be_empty
        end
      end
    end

    context "with an application choice 'pending_conditions' and another that has been 'rejected'" do
      let(:current_application_form) { create_application_form_with_course_choices(statuses: %w[pending_conditions rejected], candidate: candidate) }

      it 'renders component with rejected application choice in a table' do
        rejected_application_choice = current_application_form.application_choices.last
        result = render_inline(described_class.new(candidate: candidate))

        expect(result.css('.govuk-table__caption--m').text).to include('Your previous applications')
        expect(result.css('.app-course-choice__provider-name').text).to include(rejected_application_choice.course.provider.name)
        expect(result.css('.app-course-choice__course-name').text).to include(rejected_application_choice.course.name_and_code)
        expect(result.css('.govuk-tag').text).to include('Unsuccessful')
        expect(result.css('.govuk-link').text).to include('View application')
      end
    end
  end

  describe 'a previous application exists with a rejected application choice' do
    let(:previous_application_form) { create(:application_form, candidate: candidate, submitted_at: 10.days.ago) }
    let!(:current_application_form) { create(:application_form, candidate: candidate, submitted_at: 3.days.ago, previous_application_form_id: previous_application_form.id) }
    let!(:unsuccessful_application_choice) { create(:application_choice, :with_rejection, application_form: previous_application_form) }

    it 'renders component with rejected application choice in a table' do
      result = render_inline(described_class.new(candidate: candidate))

      expect(result.css('.govuk-table__caption--m').text).to include('Your previous applications')
      expect(result.css('.app-course-choice__provider-name').text).to include(unsuccessful_application_choice.course.provider.name)
      expect(result.css('.app-course-choice__course-name').text).to include(unsuccessful_application_choice.course.name_and_code)
      expect(result.css('.govuk-tag').text).to include('Unsuccessful')
      expect(result.css('.govuk-link').text).to include('View application')
    end
  end

  describe '#application_choices' do
    context "when an application choice has an 'ACCEPTED_STATE'" do
      let!(:application_form) { create_application_form_with_course_choices(statuses: %w[pending_conditions rejected], candidate: candidate) }

      it 'returns only the application choices that do not have ACCEPTED STATES' do
        component = described_class.new(candidate: candidate)

        expect(component.application_choices.count).to eq(1)
        expect(component.application_choices.first.status).to eq('rejected')
      end
    end

    context 'when there are application choices associated with multiple application forms' do
      let(:previous_application_form) { create(:application_form, candidate: candidate, submitted_at: 10.days.ago) }
      let!(:first_unsuccessful_application_choice) { create(:application_choice, :with_rejection, id: 1, application_form: previous_application_form) }
      let!(:second_unsuccessful_application_choice) { create(:application_choice, :with_rejection, id: 2, application_form: current_application_form) }
      let!(:third_unsuccessful_application_choice) { create(:application_choice, :with_accepted_offer, id: 3, application_form: current_application_form) }
      let!(:current_application_form) { create(:application_form, candidate: candidate, submitted_at: 3.days.ago, previous_application_form_id: previous_application_form.id) }

      it "returns all previous application choices and current application choices that do not have an 'ACCEPTED_STATE'" do
        component = described_class.new(candidate: candidate)

        expect(component.application_choices).to match_array([second_unsuccessful_application_choice, first_unsuccessful_application_choice])
      end
    end
  end

  def create_application_form_with_course_choices(statuses:, candidate:)
    application_form = create(:application_form, candidate: candidate)

    statuses.each do |status|
      create(
        :application_choice,
        application_form: application_form,
        status: status,
      )
    end

    application_form
  end
end
