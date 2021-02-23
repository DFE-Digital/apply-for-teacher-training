require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationChoiceInterviewsListComponent do
  let(:interview) { create(:interview, date_and_time: 1.hour.from_now) }
  let(:user_can_create_or_change_interviews) { true }
  let(:render) { render_inline(described_class.new(application_choice: interview.application_choice, user_can_create_or_change_interviews: user_can_create_or_change_interviews)) }

  describe 'the set up interview button' do
    context 'user_can_create_or_change_interviews is true' do
      it 'is displayed' do
        expect(render.css('.app-interviews > a').first.text).to include('Set up interview')
      end
    end

    context 'user_can_create_or_change_interviews is false' do
      let(:user_can_create_or_change_interviews) { false }

      it 'is not displayed' do
        expect(render.css('.app-interviews > a').text).not_to include('Set up interview')
      end
    end
  end

  shared_examples_for 'the interview is upcoming' do
    it 'renders the interview under the upcoming heading' do
      expect(render.css('.app-interviews > :nth-child(2)').text).to include('Upcoming interviews')
      expect(render.css('.app-interviews > :nth-child(3)').text).to include(interview.date_and_time.to_s(:govuk_date_and_time))
    end
  end

  shared_examples_for 'the interview is in the past' do
    it 'renders the interview under the past heading' do
      expect(render.css('.app-interviews > :nth-child(2)').text).to include('Past interviews')
      expect(render.css('.app-interviews > :nth-child(3)').text).to include(interview.date_and_time.to_s(:govuk_date_and_time))
    end
  end

  context 'interview is today and has not happened yet' do
    it_behaves_like 'the interview is upcoming'
  end

  context 'interview is today but has happened already' do
    let(:interview) { create(:interview, date_and_time: 1.hour.ago) }

    it_behaves_like 'the interview is upcoming'
  end

  context 'interview is tomorrow' do
    let(:interview) { create(:interview, date_and_time: 1.day.from_now) }

    it_behaves_like 'the interview is upcoming'
  end

  context 'interview was yesterday' do
    let(:interview) { create(:interview, date_and_time: 1.day.ago) }

    it_behaves_like 'the interview is in the past'
  end
end
