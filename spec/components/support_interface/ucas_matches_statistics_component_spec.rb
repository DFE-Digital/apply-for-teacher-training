require 'rails_helper'

RSpec.describe SupportInterface::UCASMatchesStatisticsComponent do
  let!(:ucas_matches) { UCASMatch.all }

  before do
    yesterday = 1.business_day.before(Time.zone.now)
    create(:completed_application_form, application_choices: [create(:submitted_application_choice)]) # not matched candidate
    create(:ucas_match, :with_multiple_acceptances)
    create(:ucas_match, :with_dual_application, action_taken: 'initial_emails_sent', candidate_last_contacted_at: yesterday)
    create(:ucas_match, :with_dual_application, action_taken: 'reminder_emails_sent', candidate_last_contacted_at: yesterday)
    create(:ucas_match, :with_dual_application, action_taken: 'ucas_withdrawal_requested', candidate_last_contacted_at: yesterday)
    create(:ucas_match, :with_dual_application, action_taken: 'resolved_on_apply', candidate_last_contacted_at: yesterday)
    create(:ucas_match, :with_dual_application, action_taken: 'resolved_on_ucas', candidate_last_contacted_at: yesterday)
    create(:ucas_match, :with_multiple_acceptances, action_taken: 'manually_resolved', candidate_last_contacted_at: yesterday)
  end

  it 'renders number of candidates on Apply' do
    result = render_inline(described_class.new(ucas_matches))

    expect(result.css('li')[0].text).to include('8 candidates on Apply with submitted application')
  end

  it 'renders number and percentage of candidates matched with UCAS' do
    result = render_inline(described_class.new(ucas_matches))

    expect(result.css('li')[1].text).to include('7 (87.50%) candidates matched with UCAS, of which')
  end

  it 'renders number of candidates that have applied for the same course on both services' do
    result = render_inline(described_class.new(ucas_matches))

    expect(result.css('li')[2].text).to include('5 (62.50% of candidates on Apply) have applied for the same course on both services')
  end

  it 'renders number of candidates that have accepted offers on both services' do
    result = render_inline(described_class.new(ucas_matches))

    expect(result.css('li')[3].text).to include('2 (25% of candidates on Apply) have accepted offers on both services')
  end

  it 'renders number of candidates with dual application or multiple acceptances' do
    result = render_inline(described_class.new(ucas_matches))

    expect(result.css('.app-card--blue')[0].text.squish).to include('7 candidates with dual application or multiple acceptances')
  end

  it 'renders the total number of unresolved matches' do
    result = render_inline(described_class.new(ucas_matches))

    expect(result.css('.app-card--blue')[1].text.squish).to include('3 unresolved')
  end

  it 'renders the number of matches resolved on UCAS' do
    result = render_inline(described_class.new(ucas_matches))

    expect(result.css('.app-card')[2].text.squish).to include('1 resolved on UCAS')
  end

  it 'renders the number of matches resolved on Apply' do
    result = render_inline(described_class.new(ucas_matches))

    expect(result.css('.app-card')[3].text.squish).to include('1 resolved on Apply')
  end

  it 'renders the number of matches resolved manually' do
    result = render_inline(described_class.new(ucas_matches))

    expect(result.css('.app-card')[4].text.squish).to include('1 resolved manually')
  end

  it 'renders the number matches we contacted the candidate and the provider about' do
    result = render_inline(described_class.new(ucas_matches))

    expect(result.css('.app-card')[5].text.squish).to include('1 set of initial emails sent')
  end

  it 'renders the number matches we sent the reminder email' do
    result = render_inline(described_class.new(ucas_matches))

    expect(result.css('.app-card')[6].text.squish).to include('1 reminder email sent')
  end

  it 'renders the number matches contacted UCAS to request withdrawal' do
    result = render_inline(described_class.new(ucas_matches))

    expect(result.css('.app-card')[7].text.squish).to include('1 UCAS withdrawal requested')
  end
end
