require 'rails_helper'

RSpec.describe ProviderInterface::StatusBoxComponents::CourseRows do
  subject(:helper) do
    helper = Class.new do
      include ProviderInterface::StatusBoxComponents::CourseRows
    end

    helper.new
  end

  it 'displays information about the offered course' do
    application_choice = build(:application_choice)
    rows = helper.course_rows(application_choice:)

    expect(rows.map { |r| r[:key] }).to contain_exactly('Course', 'Location (selected by candidate)', 'Provider', 'Full time or part time')
  end

  it 'includes the accredited_provider if present' do
    course = build(:course, accredited_provider: build(:provider))
    application_choice = build(:application_choice, course_option: build(:course_option, course:), school_placement_auto_selected: true)
    rows = helper.course_rows(application_choice:)

    expect(rows.map { |r| r[:key] }).to contain_exactly('Course', 'Location (not selected by candidate)', 'Provider', 'Full time or part time', 'Accredited body')
  end
end
