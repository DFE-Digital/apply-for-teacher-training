require 'rails_helper'

RSpec.describe CandidateInterface::OfferReviewComponent do
  include CourseOptionHelpers

  let(:course_option) { course_option_for_provider_code(provider_code: 'ABC') }
  let(:application_form) { create(:application_form, submitted_at: Time.zone.now) }
  let(:conditions) { [build(:text_condition, description: 'Fitness to train to teach check'), build(:text_condition, description: 'Be cool')] }
  let(:application_choice) do
    create(:application_choice,
           :offered,
           offer: build(:offer, conditions:),
           course_option:,
           application_form:)
  end

  it 'renders component with correct values for the provider' do
    result = render_inline(described_class.new(course_choice: application_choice))

    expect(result.css('.govuk-summary-list__key').text).to include('Provider')
    expect(result.css('.govuk-summary-list__value').text).to include(course_option.course.provider.name)
    expect(result).not_to include('References')
  end

  context 'when reference condition' do
    let(:conditions) do
      [
        build(:text_condition, text: 'Fitness to train to teach check'),
        build(:text_condition, text: 'Be cool'),
        build(:reference_condition, description: nil),
      ]
    end

    it 'renders references section' do
      render_inline(described_class.new(course_choice: application_choice)) do |rendered_component|
        expect(rendered_component).to summarise(key: 'References', value: "The provider will confirm your place once they've checked your references.")
      end
    end
  end

  context 'when Find is open' do
    it 'renders component with correct values for the course' do
      travel_temporarily_to(after_find_opens) do
        result = render_inline(described_class.new(course_choice: application_choice))

        expect(result.css('.govuk-summary-list__key').text).to include('Course')
        expect(result.css('.govuk-summary-list__value').text).to include(
          "#{course_option.course.name} (#{course_option.course.code}) (opens in new tab)",
        )
        expect(result.css('a').to_html).to include(course_option.course.find_url)
      end
    end
  end

  context 'when Find is closed' do
    it 'renders component with correct values for the course' do
      travel_temporarily_to(after_find_closes) do
        result = render_inline(described_class.new(course_choice: application_choice))

        expect(result.css('.govuk-summary-list__key').text).to include('Course')
        expect(result.css('.govuk-summary-list__value').text).to include(
          "#{course_option.course.name} (#{course_option.course.code})",
        )
        expect(result.css('a').to_html).not_to include(course_option.course.find_url)
      end
    end
  end

  context 'location row' do
    let(:application_choice) do
      build_stubbed(:application_choice,
                    :offered,
                    offer: build(:offer, conditions:),
                    course_option:,
                    school_placement_auto_selected:,
                    application_form:)
    end

    context 'when school is selected by candidate' do
      let(:school_placement_auto_selected) { false }

      it 'renders component with correct values for the location' do
        render_inline(described_class.new(course_choice: application_choice))

        expect(page).to have_content(course_option.site.name)
      end
    end

    context 'when school is auto selected' do
      let(:school_placement_auto_selected) { true }

      it 'does not render the location row' do
        render_inline(described_class.new(course_choice: application_choice))

        expect(page).to have_no_content(course_option.site.name)
      end
    end
  end

  context 'when there are conditions' do
    it 'renders component with correct values for the conditions' do
      result = render_inline(described_class.new(course_choice: application_choice))

      expect(result.css('.govuk-summary-list__key').text).to include('Conditions')
      expect(result.css('.govuk-summary-list__value').text).to include('Fitness to train to teach')
      expect(result.css('.govuk-summary-list__value').text).to include('Be cool')
    end
  end

  context 'when there are no conditions' do
    let(:application_choice) do
      create(:application_choice,
             :offered,
             offer: build(:unconditional_offer),
             course_option:,
             application_form:)
    end

    it 'does not render a conditions row' do
      result = render_inline(described_class.new(course_choice: application_choice))

      expect(result.css('.govuk-summary-list__key').text).not_to include('Conditions')
    end
  end

  context 'when the course is salaried' do
    let(:course) { create(:course, :salaried, salary_details:) }
    let(:salary_details) { 'foo-bar' }
    let(:application_choice) do
      create(:application_choice,
             :offered,
             course_option: create(:course_option, course:),
             application_form:)
    end

    it 'renders a salary row' do
      result = render_inline(described_class.new(course_choice: application_choice))

      expect(result.css('.govuk-summary-list__key').text).to include('Salary')
    end
  end

  context 'when the course is an apprenticeship' do
    let(:course) { create(:course, :apprenticeship, salary_details:) }
    let(:salary_details) { 'foo-bar' }
    let(:application_choice) do
      create(:application_choice,
             :offered,
             offer: build(:unconditional_offer),
             course_option: create(:course_option, course:),
             application_form:)
    end

    it 'renders a salaried row' do
      result = render_inline(described_class.new(course_choice: application_choice))

      expect(result.css('.govuk-summary-list__key').text).to include('Salary')
    end
  end

  context 'when no salary details are provided but the course is salaried' do
    let(:course) { create(:course, :salaried) }
    let(:application_choice) do
      create(:application_choice,
             :offered,
             course_option: create(:course_option, course:),
             application_form:)
    end

    it 'does not render a salary row' do
      result = render_inline(described_class.new(course_choice: application_choice))

      expect(result.css('.govuk-summary-list__key').text).not_to include('Salary')
    end
  end

  context 'when the course is fee paying' do
    let(:course) { create(:course, :fee_paying) }
    let(:application_choice) do
      create(:application_choice,
             :offered,
             offer: build(:unconditional_offer),
             course_option: create(:course_option, course:),
             application_form:)
    end

    it 'renders a fees row' do
      result = render_inline(described_class.new(course_choice: application_choice))

      expect(result.css('.govuk-summary-list__key').text).to include('Fees')
    end
  end
end
