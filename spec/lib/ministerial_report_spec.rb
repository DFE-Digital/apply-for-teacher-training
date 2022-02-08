require 'rails_helper'

RSpec.describe MinisterialReport do
  describe '.determine_dominant_course_subject_for_report' do
    let(:course_level) { 'secondary' }
    let(:subjects) { subject_names_and_codes.map { |name, code| create(:subject, name: name, code: code) } }
    let(:course) do
      create(
        :course,
        name: course_name,
        level: course_level,
        subjects: subjects,
      )
    end

    subject(:dominant_subject) do
      described_class.determine_dominant_course_subject_for_report(course)
    end

    context 'when the course name contains two words' do
      let(:course_name) { 'Business studies with History' }
      let(:subject_names_and_codes) { { 'Business studies' => '08', 'History' => 'V1' } }

      it { is_expected.to eq(:business_studies) }
    end

    context 'when the associated subjects are in brackets' do
      let(:course_name) { 'Modern Languages (French with Spanish)' }
      let(:subject_names_and_codes) { { 'Spanish' => '22', 'French' => '15' } }

      it { is_expected.to eq(:modern_foreign_languages) }
    end

    context 'when the course name contains no information' do
      let(:course_name) { 'Nonsense course' }
      let(:subject_names_and_codes) { { 'History' => 'V1', 'Business studies' => '08' } }

      it { is_expected.to eq(:history) }
    end

    context 'when the course is titled PE and PE is not the first subject' do
      let(:course_name) { 'PE with EBacc' }
      let(:subject_names_and_codes) { { 'Biology' => 'C1', 'Physical education' => 'C6' } }

      it { is_expected.to eq(:physical_education) }
    end

    context 'when the course is classics with latin' do
      let(:course_name) { 'Classics with Latin' }
      let(:subject_names_and_codes) { { 'Latin' => 'A0', 'Classics' => 'Q8' } }

      it { is_expected.to eq(:classics) }
    end
  end
end
