require 'rails_helper'

RSpec.describe 'RecruitmentCycleTimetables' do
  let(:response_body) { response.parsed_body }

  describe '#index' do
    let(:data) { response_body['data'] }

    it 'returns all recruitment cycle timetables in descending order' do
      get('/publications/recruitment-cycle-timetables', params: { format: 'json' })
      expect(response).to have_http_status(:ok)
      years_in_response = data.map { |timetable| timetable['recruitment_cycle_year'] }
      expect(years_in_response).to match(RecruitmentCycleTimetable.pluck(:recruitment_cycle_year).sort.reverse)
    end

    it 'does not include timestamps or id' do
      get('/publications/recruitment-cycle-timetables', params: { format: 'json' })
      expect(response).to have_http_status(:ok)
      expect(data.map { |timetable| timetable['created_at'] }.compact).to eq []
      expect(data.map { |timetable| timetable['id'] }.compact).to eq []
    end
  end

  describe '#show' do
    let(:data) { response_body['data'].first }

    context 'valid year' do
      it 'returns expected timetable' do
        year = RecruitmentCycleTimetable.pluck(:recruitment_cycle_year).sample
        get("/publications/recruitment-cycle-timetables/#{year}", params: { format: 'json' })
        expect(response).to have_http_status(:ok)
        recruitment_cycle_timetable = get_timetable(year)
        expect(data['recruitment_cycle_year']).to eq recruitment_cycle_timetable.recruitment_cycle_year
      end
    end

    context 'current year' do
      it 'returns the current recruitment cycle timetable' do
        get('/publications/recruitment-cycle-timetables/current', params: { format: 'json' })
        expect(response).to have_http_status(:ok)
        expect(data['recruitment_cycle_year']).to eq current_year
      end

      it 'does not return holiday ranges' do
        get('/publications/recruitment-cycle-timetables/current', params: { format: 'json' })
        expect(response).to have_http_status(:ok)
      end
    end

    context 'invalid year' do
      it 'returns 404 with error message' do
        get('/publications/recruitment-cycle-timetables/2018', params: { format: 'json' })
        expect(response).to have_http_status(:not_found)
        years = RecruitmentCycleTimetable.pluck(:recruitment_cycle_year)
        expect(response_body['errors'].first['message']).to eq "Recruitment cycle year should be between #{years.min} and #{years.max}"
      end
    end
  end
end
