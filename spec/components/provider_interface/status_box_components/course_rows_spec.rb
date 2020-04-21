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

    expect(rows.map { |r| r[:key] }).to match_array ['Course', 'Location', 'Provider', 'Study mode']
  end
end
