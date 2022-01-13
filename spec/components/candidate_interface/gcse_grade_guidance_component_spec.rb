require 'rails_helper'

RSpec.describe CandidateInterface::GcseGradeGuidanceComponent do
  subject(:subjects) { %w[english science maths] }

  context 'when the qualification type is O level for any subject' do
    let(:qualification_type) { 'gce_o_level' }

    it 'displays the O level guidance' do
      subjects.each do |subject|
        result = render_inline(described_class.new(subject, qualification_type))

        expect(result.text).to include(I18n.t('gcse_edit_grade.guidance.o_level_guidance'))
      end
    end
  end

  context 'when the qualification type is GCSE for any subject' do
    let(:qualification_type) { 'gcse' }

    it 'displays the GCSE guidance' do
      subjects.each do |subject|
        result = render_inline(described_class.new(subject, qualification_type))

        expect(result.text).to include(t('gcse_edit_grade.guidance.main'))
      end
    end

    context 'when the subject is English' do
      it 'shows an additional guidance message' do
        subjects = 'english'
        result = render_inline(described_class.new(subjects, qualification_type))

        expect(result.text).to include(t('gcse_edit_grade.guidance.multiple_english_gcses.secondary'))
      end
    end

    context 'when the subject is Maths or Science' do
      it 'does not show an additional guidance message' do
        subjects = %w[maths science]
        subjects.each do |subject|
          result = render_inline(described_class.new(subject, qualification_type))

          expect(result.text).not_to include(t('gcse_edit_grade.guidance.multiple_english_gcses.secondary'))
        end
      end
    end
  end

  context 'when the qualification type is Scottish National 5 for any subject' do
    let(:qualification_type) { 'scottish_national_5' }

    it 'displays the Scottish National 5 guidance' do
      subjects.each do |subject|
        result = render_inline(described_class.new(subject, qualification_type))

        expect(result.text).to include(t('gcse_edit_grade.guidance.scottish_national_5'))
      end
    end

    context 'when the subject is Science' do
      it 'displays an additional guidance message' do
        subjects = 'science'
        result = render_inline(described_class.new(subjects, qualification_type))

        expect(result.text).to include(t('gcse_edit_grade.guidance.triple_scottish_national_science'))
      end
    end

    context 'when the subject is Maths or English' do
      it 'does not show an additional guidance message' do
        subjects = %w[maths english]
        subjects.each do |subject|
          result = render_inline(described_class.new(subject, qualification_type))

          expect(result.text).not_to include(t('gcse_edit_grade.guidance.triple_scottish_national_science'))
        end
      end
    end
  end
end
