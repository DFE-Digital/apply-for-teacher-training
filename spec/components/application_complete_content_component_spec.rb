require 'rails_helper'

RSpec.describe ApplicationCompleteContentComponent do
  let(:submitted_at) { Time.zone.local(2019, 10, 22, 12, 0, 0) }

  around do |example|
    Timecop.freeze(submitted_at) do
      example.run
    end
  end

  before do
    @application_dates = instance_double(
      ApplicationDates,
      submitted_at: Time.zone.local(2019, 10, 22, 12, 0, 0),
      respond_by: Time.zone.local(2019, 12, 17, 12, 0, 0),
      edit_by: Time.zone.local(2019, 10, 29, 12, 0, 0),
      days_remaining_to_edit: 7,
      form_open_to_editing?: true,
    )
    allow(ApplicationDates).to receive(:new).and_return(@application_dates)
  end

  def render_result
    application_form = instance_double(ApplicationForm)
    render_inline(ApplicationCompleteContentComponent, application_form: application_form)
  end

  it 'renders without edit content after we have passed the expires_at date' do
    allow(@application_dates).to receive(:days_remaining_to_edit).and_return(0)
    allow(@application_dates).to receive(:form_open_to_editing?).and_return(false)
    expect(render_result.text).not_to include('Edit your application')
  end
end
