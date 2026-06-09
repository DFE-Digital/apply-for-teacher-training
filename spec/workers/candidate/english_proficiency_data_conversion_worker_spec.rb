require 'rails_helper'

RSpec.describe Candidate::EnglishProficiencyDataConversionWorker do
  describe '#perform' do
    let!(:updated_has_qualification) { create(:english_proficiency, qualification_status: 'has_qualification', has_qualification: true) }
    let!(:has_qualification_1) { create(:english_proficiency, qualification_status: 'has_qualification') }
    let!(:has_qualification_2) { create(:english_proficiency, qualification_status: 'has_qualification') }
    let!(:qualification_not_needed_1) { create(:english_proficiency, qualification_status: 'qualification_not_needed') }
    let!(:qualification_not_needed_2) { create(:english_proficiency, qualification_status: 'qualification_not_needed') }
    let!(:qualification_not_needed_3) { create(:english_proficiency, qualification_status: 'qualification_not_needed') }
    let!(:no_qualification_1) { create(:english_proficiency, qualification_status: 'no_qualification') }
    let!(:no_qualification_2) { create(:english_proficiency, qualification_status: 'no_qualification') }
    let!(:no_qualification_3) { create(:english_proficiency, qualification_status: 'no_qualification') }
    let!(:no_qualification_4) { create(:english_proficiency, qualification_status: 'no_qualification') }

    it 'toggles the boolean attribute associated with the qualification_status of each EnglishProficiency record' do
      expect { described_class.new.perform_now }.to change { EnglishProficiency.where(has_qualification: true).count }.from(1).to(3).and(
        change { EnglishProficiency.where(qualification_not_needed: true).count }.to(3).and(
          change { EnglishProficiency.where(no_qualification: true).count }.to(4),
        ),
      )

      expect(has_qualification_1.reload.has_qualification).to be(true)
      expect(has_qualification_1.reload.qualification_not_needed).to be(false)
      expect(has_qualification_1.reload.no_qualification).to be(false)

      expect(has_qualification_2.reload.has_qualification).to be(true)
      expect(has_qualification_2.reload.qualification_not_needed).to be(false)
      expect(has_qualification_2.reload.no_qualification).to be(false)

      expect(qualification_not_needed_1.reload.qualification_not_needed).to be(true)
      expect(qualification_not_needed_1.reload.has_qualification).to be(false)
      expect(qualification_not_needed_1.reload.no_qualification).to be(false)

      expect(qualification_not_needed_2.reload.qualification_not_needed).to be(true)
      expect(qualification_not_needed_2.reload.has_qualification).to be(false)
      expect(qualification_not_needed_2.reload.no_qualification).to be(false)

      expect(qualification_not_needed_3.reload.qualification_not_needed).to be(true)
      expect(qualification_not_needed_3.reload.has_qualification).to be(false)
      expect(qualification_not_needed_3.reload.no_qualification).to be(false)

      expect(no_qualification_1.reload.no_qualification).to be(true)
      expect(no_qualification_1.reload.qualification_not_needed).to be(false)
      expect(no_qualification_1.reload.has_qualification).to be(false)

      expect(no_qualification_2.reload.no_qualification).to be(true)
      expect(no_qualification_2.reload.qualification_not_needed).to be(false)
      expect(no_qualification_2.reload.has_qualification).to be(false)

      expect(no_qualification_3.reload.no_qualification).to be(true)
      expect(no_qualification_3.reload.qualification_not_needed).to be(false)
      expect(no_qualification_3.reload.has_qualification).to be(false)

      expect(no_qualification_4.reload.no_qualification).to be(true)
      expect(no_qualification_4.reload.qualification_not_needed).to be(false)
      expect(no_qualification_4.reload.has_qualification).to be(false)
    end
  end
end
