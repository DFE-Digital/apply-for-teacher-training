require 'rails_helper'

RSpec.describe BreakInWorkHistoryComponent do
  it 'contains the number of breaks in months' do
    work_experience = instance_double('ApplicationWorkExperience', id: 1)
    break_in_months = 3

    application_form = allow(GetBreaksInWorkHistory).to receive(:call).and_return(work_experience.id => break_in_months)
    component = BreakInWorkHistoryComponent.new(application_form: application_form, work_experience: work_experience)

    expect(render_inline(component).text).to include('You have a break in your work history (3 months)')
  end
end
