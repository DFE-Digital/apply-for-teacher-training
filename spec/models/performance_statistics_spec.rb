require 'rails_helper'

RSpec.describe PerformanceStatistics, type: :model do
  it 'excludes candidates with DfE addresses (as they are unlikely to be actually applying)' do
    create(:candidate, email_address: 'ab@c.com')
    create(:candidate, email_address: 'a.person@education.gov.uk')
    create(:candidate, email_address: 'another.person@digitial.education.gov.uk')

    stats = PerformanceStatistics.new

    expect(stats[:total_non_dfe_sign_ups]).to eq(1)
  end

  it 'includes only those users in each category' do
    create(:candidate)
    create_list(:application_form, 2)
    create_list(:application_form, 3, updated_at: 3.minutes.from_now) # changed forms
    create_list(:completed_application_form, 4, updated_at: 3.minutes.from_now)

    stats = PerformanceStatistics.new

    expect(stats[:total_non_dfe_sign_ups]).to eq(10)
    expect(stats[:candidates_signed_up_but_not_signed_in]).to eq(1)
    expect(stats[:candidates_signed_in_but_not_entered_data]).to eq(2)
    expect(stats[:candidates_with_unsubmitted_forms]).to eq(3)
    expect(stats[:candidates_with_submitted_forms]).to eq(4)
  end
end
