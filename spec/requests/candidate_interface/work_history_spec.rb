require 'rails_helper'

RSpec.describe 'work history section' do
  include Devise::Test::IntegrationHelpers

  let(:candidate) { create(:candidate) }

  before do
    sign_in candidate
  end

  describe 'when adding a break explanation' do
    context 'when explaining the start and end date' do
      it 'returns ok' do
        get candidate_interface_new_restructured_work_history_break_path, params: { end_date: '2019-12-01', start_date: '2018-04-01' }
        expect(response).to be_ok
      end
    end

    context 'when entering direct on the url without start date' do
      it 'redirect to work history section' do
        get candidate_interface_new_restructured_work_history_break_path
        expect(response).to redirect_to(candidate_interface_restructured_work_history_review_path)
      end
    end
  end
end
