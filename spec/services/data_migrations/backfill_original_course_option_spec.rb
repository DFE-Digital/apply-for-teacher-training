require 'rails_helper'

RSpec.describe DataMigrations::BackfillOriginalCourseOption do
  context 'when original_course_option is nil' do
    let(:application_without_original_course_option) { create(:application_choice) }

    before do
      application_without_original_course_option.update!(original_course_option: nil)
    end

    it 'backfills original_course_option column' do
      described_class.new.change

      expect(application_without_original_course_option.reload.original_course_option).to eq(application_without_original_course_option.course_option)
    end

    it 'does not touch updated_at' do
      expect { described_class.new.change }.not_to(change { application_without_original_course_option.updated_at })
    end
  end
end
