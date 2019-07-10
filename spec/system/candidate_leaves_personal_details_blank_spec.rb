require 'rails_helper'

describe 'A candidate leaves personal details blank' do
  before do
    visit '/'
    click_on t('application_form.begin_button')
    click_on t('application_form.save_and_continue')
  end

  it 'indicates there is a problem' do
    expect(page).to have_content('There is a problem')
    expect(page).to have_content('Title can\'t be blank')
  end
end
