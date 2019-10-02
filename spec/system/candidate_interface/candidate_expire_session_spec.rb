require 'rails_helper'

# TODO: This test needs to be rewritten to use the new acceptance-test style
# specs - https://github.com/DFE-Digital/apply-for-postgraduate-teacher-training/pull/246
describe 'Candidate session expires' do
  it 'expires the current candidate session' do
    candidate = FactoryBot.create(:candidate)
    login_as(candidate)

    visit candidate_interface_welcome_path
    Timecop.travel(Time.now + 7.days + 1.second) do
      visit candidate_interface_welcome_path

      expect(page).to have_current_path(candidate_interface_start_path)
    end
  end
end
