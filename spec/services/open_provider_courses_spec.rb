require 'rails_helper'

RSpec.describe OpenProviderCourses do
  let(:provider) { create(:provider, :with_user) }
  let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

  it 'opens all courses shown on Find for a given provider and emails all provider users' do
    create_list(:course, 2, provider: provider, exposed_in_find: true)
    provider_user = provider.provider_users.first
    allow(ProviderMailer).to receive(:courses_open_on_apply).and_return(mail)

    expect {
      described_class.new(provider: provider).call
    }.to(change { provider.courses.open_on_apply.count }.from(0).to(2))

    expect(ProviderMailer).to have_received(:courses_open_on_apply).with(provider_user).once
  end

  it 'does not open courses that are not exposed in Find' do
    provider = create(:provider)
    create(:course, exposed_in_find: false, provider: provider)

    expect { OpenProviderCourses.new(provider: provider).call }
      .not_to(change { Course.open_on_apply.count })
  end
end
