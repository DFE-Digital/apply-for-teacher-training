require 'rails_helper'

RSpec.describe DataMigrations::BackfillCourseOpenOnPoolInvite do
  describe '#change' do
    it 'sets the course_open field based on the course.open?' do
      invite_1 = create(
        :pool_invite,
        :sent_to_candidate,
        course: create(:course, :unavailable),
        course_open: true,
      )
      invite_2 = create(
        :pool_invite,
        :sent_to_candidate,
        course: create(:course, :open),
        course_open: false,
      )

      described_class.new.change

      expect(invite_1.reload.course_open).to be(false)
      expect(invite_2.reload.course_open).to be(true)
    end
  end
end
