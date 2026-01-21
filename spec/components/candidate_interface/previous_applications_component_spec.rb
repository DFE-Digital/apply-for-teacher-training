require 'rails_helper'

RSpec.describe CandidateInterface::PreviousApplicationsComponent do
  let(:candidate) { create(:candidate) }

  describe 'a previous application choice does not exist' do
    let!(:current_application_form) { create(:application_form, candidate:, recruitment_cycle_year: RecruitmentCycleTimetable.current_year, submitted_at: 3.days.ago) }
    let!(:withdrawn_application_choice) { create(:application_choice, :rejected, application_form: current_application_form) }

    it 'does not render component' do
      result = render_inline(described_class.new(candidate:, recruitment_cycle_year: current_application_form.recruitment_cycle_year))

      expect(result).to have_content('')
      expect(result).to have_no_content("Applications for courses in the #{current_application_form.recruitment_cycle_year - 1} to #{current_application_form.recruitment_cycle_year} recruitment cycle")
      expect(result).to have_no_content('Withdrawn')
      expect(result).to have_no_content(withdrawn_application_choice.course.provider.name)
      expect(result).to have_no_content(withdrawn_application_choice.course.name_and_code)
    end
  end

  describe 'a previous application exists with a rejected application choice' do
    let(:previous_application_form) { create(:application_form, candidate:, recruitment_cycle_year: RecruitmentCycleTimetable.current_year - 1, submitted_at: 1.year.ago) }
    let!(:current_application_form) { create(:application_form, candidate:, recruitment_cycle_year: RecruitmentCycleTimetable.current_year, submitted_at: 3.days.ago, previous_application_form_id: previous_application_form.id) }
    let!(:unsuccessful_application_choice) { create(:application_choice, :rejected, application_form: previous_application_form) }

    it 'renders component with rejected application choice' do
      result = render_inline(described_class.new(candidate:, recruitment_cycle_year: previous_application_form.recruitment_cycle_year))

      expect(result).to have_no_content("Applications for courses in the #{current_application_form.recruitment_cycle_year - 1} to #{current_application_form.recruitment_cycle_year} recruitment cycle")
      expect(result).to have_content("Applications for courses in the #{previous_application_form.recruitment_cycle_year - 1} to #{previous_application_form.recruitment_cycle_year} recruitment cycle")
      expect(result).to have_link(unsuccessful_application_choice.course.provider.name, href: "/candidate/application/choices/previous-applications/#{unsuccessful_application_choice.id}")
      expect(result).to have_content(unsuccessful_application_choice.course.name_and_code)
      expect(result).to have_content('Unsuccessful')
    end
  end

  describe 'a previous application exists with an offered application choice' do
    let(:previous_application_form) { create(:application_form, candidate:, recruitment_cycle_year: RecruitmentCycleTimetable.current_year - 1, submitted_at: 1.year.ago) }
    let!(:current_application_form) { create(:application_form, candidate:, recruitment_cycle_year: RecruitmentCycleTimetable.current_year, submitted_at: 3.days.ago, previous_application_form_id: previous_application_form.id) }
    let!(:successful_application_choice) { create(:application_choice, :offered, application_form: previous_application_form) }

    it 'renders component with offered application choice' do
      result = render_inline(described_class.new(candidate:, recruitment_cycle_year: previous_application_form.recruitment_cycle_year))

      expect(result).to have_no_content("Applications for courses in the #{current_application_form.recruitment_cycle_year - 1} to #{current_application_form.recruitment_cycle_year} recruitment cycle")
      expect(result).to have_content("Applications for courses in the #{previous_application_form.recruitment_cycle_year - 1} to #{previous_application_form.recruitment_cycle_year} recruitment cycle")
      expect(result).to have_link(successful_application_choice.course.provider.name, href: "/candidate/application/choices/previous-applications/#{successful_application_choice.id}")
      expect(result).to have_content(successful_application_choice.course.name_and_code)
      expect(result).to have_content('Offer')
    end
  end

  def create_application_form_with_course_choices(statuses:, candidate:)
    application_form = create(:application_form, candidate:)

    statuses.each do |status|
      create(
        :application_choice,
        application_form:,
        status:,
      )
    end

    application_form
  end
end
