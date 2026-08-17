require 'rails_helper'

RSpec.describe DataMigrations::BackfillCoureseStatus do
  describe '#change' do
    it 'Sets the course_status open to open courses' do
      course_open = create(:course, :open, course_status: 'closed')
      course_closed = create(:course, :closed)
      course_already_opened = create(:course, :open)

      expect { described_class.new.change }
        .to change { course_open.reload.course_status }.from('closed').to('open')
        .and(not_change { course_already_opened.reload.course_status })
        .and(not_change { course_closed.reload.course_status })
    end
  end
end
