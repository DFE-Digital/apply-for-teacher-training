require 'rails_helper'

RSpec.describe DataMigrations::DeleteUuidlessCourses do
  context 'when uuid is nil' do
    let!(:course) { create(:course, uuid: nil) }
    let!(:course_option) { create(:course_option, course: course) }

    it 'deletes courses without uuids and associated course options and subjects' do
      expect { described_class.new.change }.to change(course.course_subjects, :count).by(-1)
                                           .and change(course.course_options, :count).by(-1)
                                           .and change(Course, :count).by(-1)
    end
  end

  context 'when a course has an outstanding application' do
    let!(:course) { create(:course, uuid: nil) }
    let!(:application_choice) { create(:application_choice, course: course) }

    it 'raises an Error and doesnt delete the course' do
      expect { described_class.new.change }.to raise_error('Cannot delete courses with outstanding applications')
                                           .and change(Course, :count).by(0)
    end
  end

  context 'when uuid is not nil' do
    let!(:course) { create(:course, uuid: SecureRandom.uuid) }
    let!(:course_option) { create(:course_option, course: course) }

    it 'doesnt deletes courses with uuids or their associated course options and subjects' do
      expect { described_class.new.change }.to change(course.course_subjects, :count).by(0)
                                           .and change(course.course_options, :count).by(0)
                                           .and change(Course, :count).by(0)
    end
  end
end
