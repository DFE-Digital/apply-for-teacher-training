require 'rails_helper'

RSpec.describe FindAPI::Course do
  include FindAPIHelper

  describe '#fetch' do
    subject(:fetch_course) { FindAPI::Course.fetch('ABC', 'X123') }

    context 'when the course is available in Find' do
      before { stub_find_api_course_200('ABC', 'X123', 'Biology') }

      it 'returns the full course data' do
        expect(fetch_course.name).to eq 'Biology'
      end
    end

    context 'when the course is not found in Find' do
      before { stub_find_api_course_404('ABC', 'X123') }

      it 'returns nil' do
        expect(fetch_course).to be_nil
      end

      it 'does not report the error to Sentry' do
        allow(Raven).to receive(:capture_exception)

        fetch_course

        expect(Raven).not_to have_received(:capture_exception)
      end
    end

    context 'when Find returns a 503 error' do
      before { stub_find_api_course_503('ABC', 'X123') }

      it 'returns nil' do
        expect(fetch_course).to be_nil
      end

      it 'reports the error to Sentry' do
        allow(Raven).to receive(:capture_exception)

        fetch_course

        expect(Raven).to have_received(:capture_exception)
      end
    end

    context 'when Find is timing out' do
      before { stub_find_api_course_timeout('ABC', 'X123') }

      it 'returns nil' do
        expect(fetch_course).to be_nil
      end

      it 'reports the error to Sentry' do
        allow(Raven).to receive(:capture_exception)

        fetch_course

        expect(Raven).to have_received(:capture_exception)
      end
    end
  end

  describe '#subject_codes' do
    before do
      stub_find_api_course_200('ABC', 'X123', 'Biology')
    end

    subject(:fetch_course) { FindAPI::Course.fetch('ABC', 'X123') }

    context 'when there are subjects' do
      before do
        fetch_course.subjects = [
          FindAPI::Provider::Subject.new(
            attributes: {
              'type' => 'subjects',
              'id' => '11',
              'subject_name' => 'Business studies',
              'subject_code' => '08',
              'bursary_amount' => '9000',
              'early_career_payments' => nil,
              'scholarship' => nil,
            },
          ),
        ]
      end

      it 'returns just the codes as an Array' do
        expect(fetch_course.subject_codes).to eq(%w[08])
      end
    end

    context 'when there are no subjects' do
      before do
        fetch_course.subjects = nil
      end

      it 'does not raise an error' do
        expect { fetch_course.subject_codes }.not_to raise_error
      end

      it 'returns an empty array' do
        expect(fetch_course.subject_codes).to eq(%w[])
      end
    end
  end
end
