require 'rails_helper'

RSpec.describe CandidateInterface::GcseGradeGuidanceComponent do
  context 'when the subject is maths' do
    it 'displays the guidance around the expectation of providers' do
      subject = 'maths'

      result = render_inline(CandidateInterface::GcseGradeGuidanceComponent.new(subject, nil))

      expect(result.text).to include(t('gcse_edit_grade.guidance.main'))
    end

    it 'does not display the guidance around triple science' do
      subject = 'maths'

      result = render_inline(CandidateInterface::GcseGradeGuidanceComponent.new(subject, nil))

      expect(result.text).not_to include(t('gcse_edit_grade.guidance.triple_science'))
    end

    it 'does not display the guidance around english literature and multiple english qualifications' do
      subject = 'maths'

      result = render_inline(CandidateInterface::GcseGradeGuidanceComponent.new(subject, nil))

      expect(result.text).not_to include(t('gcse_edit_grade.guidance.english_literature_only.details'))
      expect(result.text).not_to include(t('gcse_edit_grade.guidance.multiple_english_qualifications.details'))
    end
  end

  context 'when the subject is science' do
    it 'displays the guidance around the expectation of providers' do
      subject = 'science'

      result = render_inline(CandidateInterface::GcseGradeGuidanceComponent.new(subject, nil))

      expect(result.text).to include(t('gcse_edit_grade.guidance.main'))
    end

    it 'does not display the guidance around english literature and multiple english qualifications' do
      subject = 'science'

      result = render_inline(CandidateInterface::GcseGradeGuidanceComponent.new(subject, nil))

      expect(result.text).not_to include(t('gcse_edit_grade.guidance.english_literature_only.details'))
      expect(result.text).not_to include(t('gcse_edit_grade.guidance.multiple_english_qualifications.details'))
    end

    context 'and a GCSE' do
      it 'displays the guidance around triple GCSE science' do
        subject = 'science'
        qualification_type = 'gcse'

        result = render_inline(CandidateInterface::GcseGradeGuidanceComponent.new(subject, qualification_type))

        expect(result.text).to include(t('gcse_edit_grade.guidance.triple_gcse_science'))
        expect(result.text).not_to include(t('gcse_edit_grade.guidance.triple_scottish_national_science'))
      end
    end

    context 'and a GCE O Level' do
      it 'displays the guidance around triple GCSE science' do
        subject = 'science'
        qualification_type = 'gce_o_level'

        result = render_inline(CandidateInterface::GcseGradeGuidanceComponent.new(subject, qualification_type))

        expect(result.text).to include(t('gcse_edit_grade.guidance.triple_gcse_science'))
        expect(result.text).not_to include(t('gcse_edit_grade.guidance.triple_scottish_national_science'))
      end
    end

    context 'and a Scottish National 5' do
      it 'displays the guidance around three science subjects' do
        subject = 'science'
        qualification_type = 'scottish_national_5'

        result = render_inline(CandidateInterface::GcseGradeGuidanceComponent.new(subject, qualification_type))

        expect(result.text).to include(t('gcse_edit_grade.guidance.triple_scottish_national_science'))
        expect(result.text).not_to include(t('gcse_edit_grade.guidance.triple_gcse_science'))
      end
    end

    context 'and an other UK qualification' do
      it 'does not display the guidance around triple science or three science subjects' do
        subject = 'science'
        qualification_type = 'other_uk'

        result = render_inline(CandidateInterface::GcseGradeGuidanceComponent.new(subject, qualification_type))

        expect(result.text).not_to include(t('gcse_edit_grade.guidance.triple_scottish_national_science'))
        expect(result.text).not_to include(t('gcse_edit_grade.guidance.triple_gcse_science'))
      end
    end
  end

  context 'when the subject is english' do
    it 'displays the guidance around the expectation of providers' do
      subject = 'english'

      result = render_inline(CandidateInterface::GcseGradeGuidanceComponent.new(subject, nil))

      expect(result.text).to include(t('gcse_edit_grade.guidance.main'))
    end

    it 'does not display the guidance around triple science' do
      subject = 'english'

      result = render_inline(CandidateInterface::GcseGradeGuidanceComponent.new(subject, nil))

      expect(result.text).not_to include(t('gcse_edit_grade.guidance.triple_science'))
    end

    context 'and a GCSE' do
      it 'displays the guidance around only having english literature and more than one english qualification' do
        subject = 'english'
        qualification_type = 'gcse'

        result = render_inline(CandidateInterface::GcseGradeGuidanceComponent.new(subject, qualification_type))

        expect(result.text).to include(t('gcse_edit_grade.guidance.english_literature_only.summary', type: 'a GCSE'))
        expect(result.text).to include(t('gcse_edit_grade.guidance.english_literature_only.details'))
        expect(result.text).to include(t('gcse_edit_grade.guidance.multiple_english_qualifications.summary'))
        expect(result.text).to include(t('gcse_edit_grade.guidance.multiple_english_qualifications.details'))
      end
    end

    context 'and a GCE O Level' do
      it 'displays the guidance around only having english literature and more than one english qualification' do
        subject = 'english'
        qualification_type = 'gce_o_level'

        result = render_inline(CandidateInterface::GcseGradeGuidanceComponent.new(subject, qualification_type))

        expect(result.text).to include(t('gcse_edit_grade.guidance.english_literature_only.summary', type: 'an O level'))
        expect(result.text).to include(t('gcse_edit_grade.guidance.english_literature_only.details'))
        expect(result.text).to include(t('gcse_edit_grade.guidance.multiple_english_qualifications.summary'))
        expect(result.text).to include(t('gcse_edit_grade.guidance.multiple_english_qualifications.details'))
      end
    end

    context 'and a Scottish National 5' do
      it 'does not display the guidance around english literature and multiple english qualifications' do
        subject = 'english'
        qualification_type = 'scottish_national_5'

        result = render_inline(CandidateInterface::GcseGradeGuidanceComponent.new(subject, qualification_type))

        expect(result.text).not_to include(t('gcse_edit_grade.guidance.english_literature_only.details'))
        expect(result.text).not_to include(t('gcse_edit_grade.guidance.multiple_english_qualifications.details'))
      end
    end

    context 'and an other UK qualification' do
      it 'does not display the guidance around triple science or three science subjects' do
        subject = 'english'
        qualification_type = 'other_uk'

        result = render_inline(CandidateInterface::GcseGradeGuidanceComponent.new(subject, qualification_type))

        expect(result.text).not_to include(t('gcse_edit_grade.guidance.english_literature_only.details'))
        expect(result.text).not_to include(t('gcse_edit_grade.guidance.multiple_english_qualifications.details'))
      end
    end
  end
end
