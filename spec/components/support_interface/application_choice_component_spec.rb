require 'rails_helper'

RSpec.describe SupportInterface::ApplicationChoiceComponent do
  it 'displays the date an application was rejected' do
    application_choice = create(:application_choice, :with_rejection, rejected_at: Time.zone.local(2020, 1, 1, 10, 0, 0))

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('Rejected at')
    expect(result.text).to include('1 January 2020 at 10:00am')
  end

  it 'displays the date an application was rejected by default' do
    application_choice = create(:application_choice, :with_rejection_by_default, rejected_at: Time.zone.local(2020, 1, 1, 10, 0, 0))

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('Rejected by default at')
    expect(result.text).to include('1 January 2020 at 10:00am')
  end
end
