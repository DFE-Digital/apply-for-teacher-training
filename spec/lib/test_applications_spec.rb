require 'rails_helper'

RSpec.describe TestApplications do
  it 'generates an application with choices in the given states' do
    create(:course_option, course: create(:course, open_on_apply: true))
    create(:course_option, course: create(:course, open_on_apply: true))

    choices = TestApplications.create_application(states: %i[offer rejected])

    expect(choices.count).to eq(2)
  end

  it 'throws an exception if there aren’t enough courses to apply to' do
    expect {
      TestApplications.create_application(states: %i[offer])
    }.to raise_error(/Not enough distinct courses/)
  end
end
