require 'rails_helper'

RSpec.describe InterviewBookingsComponent, type: :component do
  around do |example|
    Timecop.freeze(2020, 6, 1, 12) do
      example.run
    end
  end

  let(:interview) do
    create(
      :interview,
      date_and_time: Time.zone.local(2020, 6, 6, 18, 30),
    )
  end

  it 'renders the interview time' do
    result = render_inline(described_class.new(interview.application_choice))
    expect(result.text).to include('6 June 2020 at 6:30pm')
  end

  it 'renders the location, with breaks and hyperlinks' do
    interview.update!(
      location: "123\nTest Street\nLondon\nCheck this if you get lost https://www.googlemaps.com",
    )
    result = render_inline(described_class.new(interview.application_choice))
    expected_markup = <<-HTML
      <p class="govuk-body">123
      <br>Test Street
      <br>London
      <br>Check this if you get lost <a href="https://www.googlemaps.com">https://www.googlemaps.com</a></p>
    HTML

    expect(result.to_html.squish).to include(expected_markup.squish)
  end

  it 'renders additional_details, with breaks and hyperlinks' do
    interview.update!(
      additional_details: "Backup Zoom call if the trains are cancelled \n https://us02web.zoom.us/j/foo",
    )
    result = render_inline(described_class.new(interview.application_choice))
    expected_markup = <<-HTML
      <p class="govuk-body">Backup Zoom call if the trains are cancelled
      <br> <a href="https://us02web.zoom.us/j/foo">https://us02web.zoom.us/j/foo</a></p>
    HTML

    expect(result.to_html.squish).to include(expected_markup.squish)
  end

  context 'when location contains undesireable HTML tags' do
    it 'removes them' do
      interview.update!(location: "l33t hax <script>alert('pwned')</script>")
      result = render_inline(described_class.new(interview.application_choice))

      expect(result.to_html).to include 'l33t hax'
      expect(result.to_html).not_to include 'script'
    end
  end

  context 'when location contains a URI with the javascript protocol' do
    it 'does not turn it into a link' do
      interview.update!(location: "javascript:alert('hi')")
      render_inline(described_class.new(interview.application_choice))

      expect(page).to have_content "javascript:alert('hi')"
      expect(page.has_link?('javascript')).to eq false
    end
  end

  context 'when additional_details contains undesireable HTML tags' do
    it 'removes them' do
      interview.update!(additional_details: "l33t hax <script>alert('pwned')</script>")
      result = render_inline(described_class.new(interview.application_choice))

      expect(result.to_html).to include 'l33t hax'
      expect(result.to_html).not_to include 'script'
    end
  end

  context 'when additional_details contains a URI with the javascript protocol' do
    it 'does not turn it into a link' do
      interview.update!(additional_details: "javascript:alert('hi')")
      render_inline(described_class.new(interview.application_choice))

      expect(page).to have_content "javascript:alert('hi')"
      expect(page.has_link?('javascript')).to eq false
    end
  end

  context 'when there is more than one interview for the application choice' do
    before { interview.update!(additional_details: 'This is interview 1') }

    let!(:additional_interview) do
      create(
        :interview,
        additional_details: 'This is interview 2',
        application_choice: interview.application_choice,
      )
    end

    it 'renders them in a numbered list' do
      result = render_inline(described_class.new(interview.application_choice))

      expect(result.to_html).to include '<ul class="govuk-list govuk-list--number">'
      expect(result.text).to include 'This is interview 1'
      expect(result.text).to include 'This is interview 2'
    end
  end

  context 'when the interview is in the past' do
    it 'renders a simple message with the date' do
      Timecop.freeze(2020, 6, 7, 12) do
        result = render_inline(described_class.new(interview.application_choice))
        expect(result.text).to include('You had an interview on 6 June 2020')
      end
    end
  end

  context 'when no interviews are scheduled' do
    it 'renders nothing if the application is not awaiting a provider decision' do
      application_choice = create(:application_choice, status: 'rejected')
      result = render_inline(described_class.new(application_choice))

      expect(result.text).to be_blank
    end

    it 'renders a message if the application is awaiting a provider decision' do
      application_choice = create(:application_choice, status: 'awaiting_provider_decision')
      result = render_inline(described_class.new(application_choice))

      expect(result.text).to include('The provider will be in touch if they want to invite you to an interview')
    end
  end
end
