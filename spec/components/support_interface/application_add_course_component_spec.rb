require 'rails_helper'

RSpec.describe SupportInterface::ApplicationAddCourseComponent do
  context 'application is submitted and has less than three application choices' do
    it "renders the 'add a course' button" do
      application_form = create(:completed_application_form)

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-button').text).to include('Add a course')
    end
  end

  context 'application is submitted and has three application choices including one that is withdrawn' do
    it "renders the 'add a course' button" do
      application_form = create(:completed_application_form)
      create_list(:submitted_application_choice, 3, application_form_id: application_form.id)

      withdrawn_application_choice = application_form.application_choices.last
      ApplicationStateChange.new(withdrawn_application_choice).withdraw!
      withdrawn_application_choice.update(withdrawn_at: Time.zone.now)

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-button').text).to include('Add a course')
    end
  end

  context 'application is submitted and has more than three application choices' do
    it "does not render the 'add a course' button" do
      application_form = create(:completed_application_form)

      create_list(:submitted_application_choice, 4, application_form_id: application_form.id)

      application_form.reload

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-button').text).not_to include('Add a course')
    end
  end

  context 'application is unsubmitted and has less than three application choices' do
    it "does not render the 'add a course' button" do
      application_form = create(:application_form)

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-button').text).not_to include('Add a course')
    end
  end
end
