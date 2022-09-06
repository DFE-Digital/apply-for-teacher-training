require 'rails_helper'

RSpec.describe ProviderInterface::StatusBoxComponents::CourseRows do
  subject(:helper) do
    helper = Class.new do
      include ProviderInterface::StatusBoxComponents::CourseRows
    end

    helper.new
  end

  it 'displays information about the offered course' do
    rows = helper.course_rows(course_option: create(:course_option))

    expect(rows.map { |r| r[:key] }).to match_array ['Course', 'Location', 'Provider', 'Full time or part time']
  end

  it 'includes the accredited_provider if present' do
    course = create(:course, accredited_provider: create(:provider))
    rows = helper.course_rows(course_option: create(:course_option, course:))

    expect(rows.map { |r| r[:key] }).to match_array ['Course', 'Location', 'Provider', 'Full time or part time', 'Accredited body']
  end
end
