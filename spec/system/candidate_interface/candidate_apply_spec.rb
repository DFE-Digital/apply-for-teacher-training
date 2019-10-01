require 'rails_helper'

describe 'A candidate applying from Find' do
  let(:provider_code) { '1AB' }
  let(:course_code) { '2ABC' }

  before do
    visit candidate_interface_apply_path providerCode: provider_code, courseCode: course_code
  end

  it 'sees the apply page' do
    expect(page).to have_content t('apply.heading')
  end

  it 'sees their provider code' do
    expect(page).to have_content provider_code
  end

  it 'sees their course code' do
    expect(page).to have_content course_code
  end

  it 'can apply through UCAS' do
    expect(page).to have_content t('apply.apply_button')
  end
end
