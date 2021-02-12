require 'rails_helper'

RSpec.describe ProviderInterface::InterviewDetailsComponent do
  let(:date_and_time) { Time.zone.local(2020, 1, 12, 15, 30) }
  let(:provider) { build_stubbed(:provider, name: 'Teaching School') }
  let(:application_choice) { build_stubbed(:application_choice, id: 1) }
  let(:location) { 'Zoom' }
  let(:additional_details) { 'Do not be late' }
  let(:interview_form) do
    instance_double(
      ProviderInterface::InterviewWizard,
      date_and_time: date_and_time,
      provider: provider,
      location: location,
      additional_details: additional_details,
      application_choice: application_choice,
    )
  end
  let(:render) { render_inline(described_class.new(interview_form)).text }

  it 'renders the interview date' do
    expect(render).to include('12 January 2020')
  end

  it 'renders the interview time' do
    expect(render).to include('3:30pm')
  end

  it 'renders the provider name' do
    expect(render).to include('Teaching School')
  end

  it 'renders the interview location' do
    expect(render).to include('Zoom')
  end

  it 'renders additional_details' do
    expect(render).to include('Do not be late')
  end

  context 'no additional_details are set' do
    let(:additional_details) { '' }

    it 'renders None in the additional details row' do
      expect(render).to include('Additional details')
      expect(render).to include('None')
    end
  end
end
