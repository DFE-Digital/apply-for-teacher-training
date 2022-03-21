require 'rails_helper'

RSpec.describe ProviderInterface::InterviewCardComponent do
  let(:application_choice) { build_stubbed(:application_choice, application_form: application_form, course_option: course_option) }
  let(:course_option) { create(:course_option, course: build(:course)) }
  let(:application_form) do
    build_stubbed(:application_form,
                  interview_preferences: 'Only available Tuesdays and Thursdays',
                  first_name: 'Kara',
                  last_name: 'Thrace')
  end
  let(:interview) { build_stubbed(:interview, application_choice: application_choice) }
  let(:render) { render_inline(described_class.new(interview: interview)) }

  it 'renders the candidate name' do
    expect(render.css('.app-interview-card__candidate').text).to include('Kara Thrace')
  end

  it 'renders the application course' do
    expect(render.css('.app-interview-card__course').text).to include(course_option.course.name)
  end

  it 'renders the interview time' do
    expect(render.css('.app-interview-card__time').text).to include(interview.date_and_time.to_fs(:govuk_time))
  end

  it 'renders text indicating there are interview preferences if any' do
    expect(render.css('.app-interview-card__candidate').text).to include('Has interview preferences')
  end

  it 'renders the application choice interviews anchored url' do
    expect(render.css('a').attr('href').value).to eq("/provider/applications/#{application_choice.id}/interviews#interview-#{interview.id}")
  end
end
