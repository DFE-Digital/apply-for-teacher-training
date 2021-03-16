require 'rails_helper'

RSpec.describe GcseQualificationCardsComponent, type: :component do
  describe 'rendering maths' do
    context 'when it\'s a standard UK qualification' do
      let(:application_form) do
        create(
          :application_form,
          application_qualifications: [create(:gcse_qualification, subject: 'maths', grade: 'C', award_year: 2006)],
        )
      end

      it 'renders all expected detail' do
        result = render_inline(described_class.new(application_form))

        expect(result.text).to include 'GCSEs or equivalent'
        expect(result.text).to include 'Maths GCSE'
        expect(result.text).to include '2006'
        expect(result.text).to include 'C'
      end
    end

    context 'when it\'s a uk_other qualification' do
      let(:application_form) do
        create(
          :application_form,
          application_qualifications: [
            create(
              :gcse_qualification,
              qualification_type: 'other_uk',
              other_uk_qualification_type: 'Standard Grade',
              subject: 'maths',
              grade: 'C',
              award_year: 2006,
            ),
          ],
        )
      end

      it 'renders all expected detail' do
        result = render_inline(described_class.new(application_form))

        expect(result.text).to include 'GCSEs or equivalent'
        expect(result.text).to include 'Maths Standard Grade'
        expect(result.text).to include '2006'
        expect(result.text).to include 'C'
      end
    end

    context 'when it\'s a non_uk qualification' do
      let(:application_form) do
        create(
          :application_form,
          application_qualifications: [
            create(
              :gcse_qualification,
              :non_uk,
              subject: 'maths',
              grade: 'C',
              award_year: 2006,
              non_uk_qualification_type: 'Diploma',
              institution_country: 'FR',
            ),
          ],
        )
      end

      it 'renders all expected detail' do
        result = render_inline(described_class.new(application_form))

        expect(result.text).to include 'GCSEs or equivalent'
        expect(result.text).to include 'Maths Diploma'
        expect(result.text).to include '2006, France'
        expect(result.text).to include 'C'
        expect(result.text).to include 'UK ENIC statement 4000123456 says this is comparable to a Between GCSE and GCSE AS Level.'
      end

      context 'when the UK ENIC reference is not provided' do
        before { application_form.maths_gcse.update(enic_reference: nil) }

        it 'does not show a UK ENIC statement' do
          result = render_inline(described_class.new(application_form))
          expect(result.text).not_to include 'UK ENIC'
        end
      end
    end

    context 'when it\'s of type "missing"' do
      let(:application_form) do
        create(
          :application_form,
          application_qualifications: [create(:gcse_qualification, :missing)],
        )
      end

      it 'renders details about the lack of this qualification' do
        result = render_inline(described_class.new(application_form))

        expect(result.text).to include 'GCSEs or equivalent'
        expect(result.text).to include 'Candidate does not have this qualification yet'
        expect(result.text).to include 'I will be taking an equivalency test in a few weeks'
      end
    end
  end

  describe 'rendering english' do
    let(:application_form) do
      create(
        :application_form,
        application_qualifications: [create(:gcse_qualification, subject: 'english', grade: 'C', award_year: 2006)],
      )
    end

    it 'renders all expected detail' do
      result = render_inline(described_class.new(application_form))

      expect(result.text).to include 'GCSEs or equivalent'
      expect(result.text).to include 'English GCSE'
      expect(result.text).to include '2006'
      expect(result.text).to include 'C'
    end
  end

  describe 'rendering science' do
    let(:application_form) do
      create(
        :application_form,
        application_qualifications: [create(:gcse_qualification, subject: 'science', grade: 'C', award_year: 2006)],
      )
    end

    it 'renders all expected detail' do
      result = render_inline(described_class.new(application_form))

      expect(result.text).to include 'GCSEs or equivalent'
      expect(result.text).to include 'Science GCSE'
      expect(result.text).to include '2006'
      expect(result.text).to include 'C'
    end
  end

  describe 'rendering a set of three cards' do
    let(:application_form) do
      create(
        :application_form,
        application_qualifications: [
          create(:gcse_qualification, subject: 'maths', grade: 'C', award_year: 2006),
          create(:gcse_qualification, subject: 'english', grade: 'C', award_year: 2006),
          create(:gcse_qualification, subject: 'science', grade: 'C', award_year: 2006),
        ],
      )
    end

    it 'renders cards for maths, english, and science' do
      result = render_inline(described_class.new(application_form))

      cards = result.css('.app-card--outline').each
      expect(cards.next.text).to include 'Maths'
      expect(cards.next.text).to include 'English'
      expect(cards.next.text).to include 'Science'
    end
  end

  describe 'rendering multiple English GCSEs' do
    let(:application_form) do
      create(
        :application_form,
        application_qualifications: [
          create(:gcse_qualification, subject: 'english', constituent_grades: { english_language: { grade: 'E' }, english_literature: { grade: 'E' }, "Cockney Rhyming Slang": { grade: 'A*' } }, award_year: 2006),
        ],
      )
    end

    it 'renders grades for multiple English GCSEs' do
      result = render_inline(described_class.new(application_form))

      card = result.css('.app-card--outline')

      expect(card.text).to include 'E (English Language)'
      expect(card.text).to include 'E (English Literature)'
      expect(card.text).to include 'A* (Cockney Rhyming Slang)'
    end
  end

  describe 'rendering multiple Science GCSEs' do
    science_triple_awards = {
      biology: { grade: 'A' },
      chemistry: { grade: 'B' },
      physics: { grade: 'C' },
    }

    let(:application_form) do
      create(
        :application_form,
        application_qualifications: [
          create(:gcse_qualification, subject: 'science triple award', constituent_grades: science_triple_awards, award_year: 2006),
        ],
      )
    end

    it 'renders grades for multiple English GCSEs' do
      result = render_inline(described_class.new(application_form))

      card = result.css('.app-card--outline')

      expect(card.text).to include 'A (Biology)'
      expect(card.text).to include 'B (Chemistry)'
      expect(card.text).to include 'C (Physics)'
    end
  end
end
