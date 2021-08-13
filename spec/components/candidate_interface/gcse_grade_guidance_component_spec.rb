require 'rails_helper'

RSpec.describe CandidateInterface::GcseGradeGuidanceComponent do
  context 'when the subject is maths' do
    it 'displays the guidance around the expectation of providers' do
      subject = 'maths'

      result = render_inline(described_class.new(subject, nil))

      expect(result.text).to include(t('gcse_edit_grade.guidance.main'))
    end

    it 'does not display the guidance around triple science' do
      subject = 'maths'

      result = render_inline(described_class.new(subject, nil))

      expect(result.text).not_to include(t('gcse_edit_grade.guidance.o_level_triple_gcse_science'))
    end

    it 'does not display the guidance around english literature and multiple english qualifications' do
      subject = 'maths'

      result = render_inline(described_class.new(subject, nil))

      expect(result.text).not_to include(t('gcse_edit_grade.guidance.multiple_english_gcses.main'))
      expect(result.text).not_to include(t('gcse_edit_grade.guidance.multiple_english_gcses.secondary'))
    end
  end

  context 'when the subject is science' do
    it 'displays the guidance around the expectation of providers' do
      subject = 'science'

      result = render_inline(described_class.new(subject, nil))

      expect(result.text).to include(t('gcse_edit_grade.guidance.main'))
    end

    it 'does not display the guidance around english literature and multiple english qualifications' do
      subject = 'science'

      result = render_inline(described_class.new(subject, nil))

      expect(result.text).not_to include(t('gcse_edit_grade.guidance.multiple_english_gcses.main'))
      expect(result.text).not_to include(t('gcse_edit_grade.guidance.multiple_english_gcses.secondary'))
    end

    context 'and a GCSE' do
      it 'displays the guidance around triple GCSE science' do
        subject = 'science'
        qualification_type = 'gcse'

        result = render_inline(described_class.new(subject, qualification_type))

        expect(result.text).to include(t('gcse_edit_grade.guidance.o_level_triple_gcse_science'))
        expect(result.text).not_to include(t('gcse_edit_grade.guidance.triple_scottish_national_science'))
      end
    end

    context 'and an O Level' do
      it 'displays the guidance around triple GCSE science' do
        subject = 'science'
        qualification_type = 'gce_o_level'

        result = render_inline(described_class.new(subject, qualification_type))

        expect(result.text).to include(t('gcse_edit_grade.guidance.o_level_triple_gcse_science'))
        expect(result.text).not_to include(t('gcse_edit_grade.guidance.triple_scottish_national_science'))
      end
    end

    context 'and a Scottish National 5' do
      it 'displays the guidance around three science subjects' do
        subject = 'science'
        qualification_type = 'scottish_national_5'

        result = render_inline(described_class.new(subject, qualification_type))

        expect(result.text).to include(t('gcse_edit_grade.guidance.triple_scottish_national_science'))
        expect(result.text).not_to include(t('gcse_edit_grade.guidance.o_level_triple_gcse_science'))
      end
    end

    context 'and an other UK qualification' do
      it 'does not display the guidance around triple science or three science subjects' do
        subject = 'science'
        qualification_type = 'other_uk'

        result = render_inline(described_class.new(subject, qualification_type))

        expect(result.text).not_to include(t('gcse_edit_grade.guidance.triple_scottish_national_science'))
        expect(result.text).not_to include(t('gcse_edit_grade.guidance.o_level_triple_gcse_science'))
      end
    end
  end

  context 'when the subject is english' do
    it 'displays the guidance around the expectation of providers for multiple English GCSEs' do
      subject = 'english'

      result = render_inline(described_class.new(subject, 'gcse'))

      expect(result.text).to include(t('gcse_edit_grade.guidance.multiple_english_gcses.main'))
      expect(result.text).to include(t('gcse_edit_grade.guidance.multiple_english_gcses.secondary'))
    end

    it 'does not display the guidance around triple science' do
      subject = 'english'

      result = render_inline(described_class.new(subject, nil))

      expect(result.text).not_to include(t('gcse_edit_grade.guidance.o_level_triple_gcse_science'))
    end

    context 'and a Scottish National 5' do
      it 'does not display the guidance around english literature and multiple english qualifications' do
        subject = 'english'
        qualification_type = 'scottish_national_5'

        result = render_inline(described_class.new(subject, qualification_type))

        expect(result.text).not_to include(t('gcse_edit_grade.guidance.multiple_english_gcses.main'))
        expect(result.text).not_to include(t('gcse_edit_grade.guidance.multiple_english_gcses.secondary'))
      end
    end

    context 'and an other UK qualification' do
      it 'does not display the guidance around triple science or three science subjects' do
        subject = 'english'
        qualification_type = 'other_uk'

        result = render_inline(described_class.new(subject, qualification_type))

        expect(result.text).not_to include(t('gcse_edit_grade.guidance.multiple_english_gcses.main'))
        expect(result.text).not_to include(t('gcse_edit_grade.guidance.multiple_english_gcses.secondary'))
      end
    end
  end
end
