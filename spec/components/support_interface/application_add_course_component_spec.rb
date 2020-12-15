require 'rails_helper'

RSpec.describe SupportInterface::ApplicationAddCourseComponent do
  context 'application is submitted and has less than three application choices' do
    it "renders the 'add a course' button" do
      application_form = create(:completed_application_form)

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-button').text).to include('Add a course')
    end
  end

  context 'application is submitted and has more than three application choices' do
    it "does not render the 'add a course' button" do
      application_form = create(:completed_application_form)

      create_list(:application_choice, 4, application_form_id: application_form.id)

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
