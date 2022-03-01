require 'rails_helper'

RSpec.describe CandidateInterface::DegreeCompletionStatusForm, type: :model do
  it 'validates presence of degree_completed' do
    form = described_class.new
    expect(form).not_to be_valid
    expect(form.errors.full_messages).to include 'Degree completed Select if you have completed your degree or not'
  end

  describe '#save(degree)' do
    it 'sets degree.predicted_grade to true if the degree_completed attr is "no"' do
      degree = build(:degree_qualification, predicted_grade: nil)
      form = described_class.new(degree_completed: 'no')

      form.save(degree)

      expect(degree.reload.predicted_grade).to be true
    end

    it 'sets degree.predicted_grade to false if the degree_completed attr is "yes"' do
      degree = build(:degree_qualification, predicted_grade: nil)
      form = described_class.new(degree_completed: 'yes')

      form.save(degree)

      expect(degree.reload.predicted_grade).to be false
    end
  end

  describe '#update' do
    it 'sets degree.predicted_grade to false when previously true and sets award year to nil' do
      degree = build(:degree_qualification, predicted_grade: true, award_year: RecruitmentCycle.next_year)
      form = described_class.new(degree_completed: 'yes')

      form.update(degree)

      expect(degree.reload.predicted_grade).to be false
      expect(degree.award_year).to be_nil
    end

    it 'sets degree.predicted_grade to true when previously false and sets award year to nil' do
      degree = build(:degree_qualification, predicted_grade: false, award_year: RecruitmentCycle.current_year)
      form = described_class.new(degree_completed: 'no')

      form.update(degree)

      expect(degree.reload.predicted_grade).to be true
      expect(degree.award_year).to be_nil
    end
  end

  describe '#assign_form_values(degree)' do
    it 'sets degree_completed to "no" if degree.predicted_grade? is true' do
      degree = build_stubbed(:degree_qualification, predicted_grade: true)
      form = described_class.new
      form.assign_form_values(degree)

      expect(form.degree_completed).to eq 'no'
    end

    it 'sets degree_completed to "yes" if degree.predicted_grade? is false' do
      degree = build_stubbed(:degree_qualification, predicted_grade: false)
      form = described_class.new
      form.assign_form_values(degree)

      expect(form.degree_completed).to eq 'yes'
    end

    it 'does not set degree_completed if degree.predicted_grade is nil' do
      degree = build_stubbed(:degree_qualification, predicted_grade: nil)
      form = described_class.new
      form.assign_form_values(degree)

      expect(form.degree_completed).to be_nil
    end
  end
end
