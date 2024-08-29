require 'rails_helper'

RSpec.describe DataMigrations::SetSelectableSchoolsOnProviders do
  it 'sets `selectable_school to true for all providers codes' do
    target_provider = create(:provider, selectable_school: false, code: '1ZO')
    ignore_provider = create(:provider, selectable_school: false, code: 'XXX')

    described_class.new.change

    expect(target_provider.reload.selectable_school).to be(true)
    expect(ignore_provider.reload.selectable_school).to be(false)
  end
end
