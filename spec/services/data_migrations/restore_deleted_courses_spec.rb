require 'rails_helper'

RSpec.describe DataMigrations::RestoreDeletedCourses do
  before do
    # Provider IDs are hard-coded in the migration
    create(:provider, :no_users, id: 55)
    create(:provider, :no_users, id: 2033)
    create(:provider, :no_users, id: 29)
    create(:provider, :no_users, id: 475)
    create(:provider, :no_users, id: 1417)

    # Subject IDs are hard-coded in the migration
    create(:subject, id: 2)
    create(:subject, id: 26)
    create(:subject, id: 29)

    # Site IDs are hard-coded in the migration
    create(:site, id: 13479781)
    create(:site, id: 13481975)
    create(:site, id: 13482125)
    create(:site, id: 13486326)
    create(:site, id: 13491128)
    create(:site, id: 13491103)
    create(:site, id: 13522635)
  end

  it 'creates Courses' do
    expect {
      described_class.new.change
    }.to change(Course, :count).by(5)

    expect(Course.pluck(:id)).to contain_exactly(58058, 58703, 60253, 60784, 66304)

    expect(Course.pluck(:provider_id)).to contain_exactly(55, 2033, 29, 475, 1417)
  end

  it 'creates Course Subjects' do
    expect {
      described_class.new.change
    }.to change(CourseSubject, :count).by(5)
  end

  it 'creates Course Options' do
    expect {
      described_class.new.change
    }.to change(CourseOption, :count).by(7)
  end
end
