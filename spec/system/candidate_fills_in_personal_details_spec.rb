require 'rails_helper'

RSpec.describe 'A candidate filling in their personal details' do
  it 'can enter details into the form, and see them on the finished application' do
    visit '/'
    click_on t('application_form.begin_button')

    expect(page).to have_content t('application_form.personal_details_section.heading')
  end
end
