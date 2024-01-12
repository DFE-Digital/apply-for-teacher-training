require 'rails_helper'

RSpec.describe 'Non logged in user can visit guidance' do
  context 'when continuous applications mid cycle' do
    context 'when mid cycle', time: mid_cycle do
      scenario 'User can visit the guidance page without session' do
        visit(candidate_interface_guidance_path)
        expect(page).to have_content('Apply for teacher training')
      end
    end

    context 'when after_apply_reopens', time: after_apply_reopens do
      scenario 'User can visit the guidance page without session' do
        visit(candidate_interface_guidance_path)
        expect(page).to have_content('Apply for teacher training')
      end
    end
  end
end
