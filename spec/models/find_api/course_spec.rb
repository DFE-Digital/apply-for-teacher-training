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
    end

    context 'when Find returns a 503 error' do
      before { stub_find_api_course_503('ABC', 'X123') }

      it 'returns a skeleton course with no information added' do
        expect(fetch_course.provider_code).to eq 'ABC'
        expect(fetch_course.name).to be_nil
      end
    end

    context 'when Find is timing out' do
      before { stub_find_api_course_timeout('ABC', 'X123') }

      it 'returns a skeleton course with no information added' do
        expect(fetch_course.provider_code).to eq 'ABC'
        expect(fetch_course.name).to be_nil
      end
    end
  end
end
