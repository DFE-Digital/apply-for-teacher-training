require 'rails_helper'

RSpec.describe ApplicationDateComponent do
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

  def render_result(type)
    application_form = instance_double(ApplicationForm)
    render_inline(ApplicationDateComponent, application_form: application_form, type: type)
  end

  it 'renders with correct submission date' do
    expect(render_result(:submitted_at).text).to include('22 October 2019')
  end

  it 'renders with correct respond by date' do
    expect(render_result(:respond_by).text).to include('17 December 2019')
  end

  it 'renders with correct edit by date' do
    expect(render_result(:edit_by).text).to include('29 October 2019')
  end

  it 'renders with correct days remaining 2 days after submission' do
    allow(@application_dates).to receive(:days_remaining_to_edit).and_return(5)
    expect(render_result(:days_remaining).text).to include('5 days')
  end
end
