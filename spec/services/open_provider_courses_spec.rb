require 'rails_helper'

RSpec.describe OpenProviderCourses do
  it 'opens all courses shown on Find for a given provider' do
    provider = create(:provider)
    create_list(:course, 2, exposed_in_find: true, provider: provider)

    expect { OpenProviderCourses.new(provider: provider).call }
      .to(change { Course.open_on_apply.count }.from(0).to(2))
  end

  it 'does not open courses that are not exposed in Find' do
    provider = create(:provider)
    create(:course, exposed_in_find: false, provider: provider)

    expect { OpenProviderCourses.new(provider: provider).call }
      .not_to(change { Course.open_on_apply.count })
  end
end
