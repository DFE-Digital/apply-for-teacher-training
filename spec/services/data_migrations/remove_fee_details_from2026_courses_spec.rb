require 'rails_helper'

RSpec.describe DataMigrations::RemoveFeeDetailsFrom2026Courses do
  it 'changes fee details to nil where they exist only on 2026 courses' do
    course_2026_no_fee_details = create(:course, recruitment_cycle_year: 2026, fee_details: nil)
    course_2026_with_fee_details = create(:course, recruitment_cycle_year: 2026, fee_details: 'irrelevant information from 2025')
    course_2025_with_fee_details = create(:course, recruitment_cycle_year: 2025, fee_details: 'relevant information from 2025')

    described_class.new.change
    expect(course_2025_with_fee_details.reload.fee_details).to eq 'relevant information from 2025'
    expect(course_2026_with_fee_details.reload.fee_details).to be_nil
    expect(course_2026_no_fee_details.reload.fee_details).to be_nil
  end
end
