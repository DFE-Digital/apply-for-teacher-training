require 'rails_helper'

RSpec.describe DegreeQualificationCardsComponent, type: :component do
  describe 'rendering a degree' do
    let(:degree) do
      create(
        :degree_qualification,
        qualification_type: 'Bachelor of Arts',
        subject: 'Computer science',
        institution_name: 'The University of Oxford',
        grade: 'First class honours',
        predicted_grade: false,
      )
    end

    it 'renders all expected detail' do
      result = render_inline described_class.new([degree])

      expect(result.text).to include 'BA (Hons) Computer science'
      expect(result.text).to include degree.start_year
      expect(result.text).to include degree.award_year
      expect(result.text).to include 'Grade'
      expect(result.text).to include 'First class honours'
      expect(result.text).to include 'Institution'
      expect(result.text).to include 'The University of Oxford'
      expect(result.text).not_to include 'HESA codes'
    end

    it 'renders all expected detail including HESA codes' do
      result = render_inline described_class.new([degree], show_hesa_codes: true)

      expect(result.text).to include 'BA (Hons) Computer science'
      expect(result.text).to include degree.start_year
      expect(result.text).to include degree.award_year
      expect(result.text).to include 'Grade'
      expect(result.text).to include 'First class honours'
      expect(result.text).to include 'Institution'
      expect(result.text).to include 'The University of Oxford'
      expect(result.text).to include 'HESA codes'
      expect(result.text).to include "Type: #{Hesa::DegreeType.find_by_name(degree.qualification_type)&.hesa_code}"
      expect(result.text).to include "Subject: #{Hesa::Subject.find_by_name(degree.subject)&.hesa_code}"
      expect(result.text).to include "Establishment: #{Hesa::Institution.find_by_name(degree.institution_name)&.hesa_code}"
      expect(result.text).to include "Class: #{Hesa::Grade.find_by_description(degree.grade)&.hesa_code}"
    end

    context 'when it is an international degree' do
      before { degree.update(international: true, institution_country: 'AF') }

      it 'renders the institution country' do
        result = render_inline described_class.new([degree])
        expect(result.text).to include 'The University of Oxford, Afghanistan'
      end

      it 'renders the institution even when the offer has not been accepted yet' do
        (ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER - ApplicationStateChange::ACCEPTED_STATES).each do |state|
          result = render_inline described_class.new([degree], application_choice_state: state)
          expect(result.text).to include 'The University of Oxford'
        end
      end
    end

    context 'when the grade is predicted' do
      before { degree.update(predicted_grade: true) }

      it 'renders a prefix when displaying the grade' do
        result = render_inline described_class.new([degree])
        expect(result.text).to include 'Predicted: First class honours'
      end
    end

    context 'when UK ENIC details are provided' do
      before { degree.update(enic_reference: '1234', comparable_uk_degree: 'masters_degree') }

      it 'renders a UK ENIC statement' do
        result = render_inline described_class.new([degree])
        expect(result.text).to include(
          'UK ENIC or NARIC statement 1234 says this is comparable to a Master’s degree / Integrated Master’s degree',
        )
      end
    end

    context 'when the grade is not honours' do
      before { degree.update(grade: 'Pass') }

      it 'does not display (Hons) after the degree type' do
        result = render_inline described_class.new([degree])
        expect(result.text).to include 'BA Computer science'
      end
    end

    describe 'deciding on displaying the institution' do
      it 'is visible when no application_choice state is specified' do
        result = render_inline described_class.new([degree])
        expect(result.text).to include 'Institution'
        expect(result.text).to include 'The University of Oxford'
      end

      it 'is visible when the application_choice state is in one of the ACCEPTED_STATES' do
        ApplicationStateChange::ACCEPTED_STATES.each do |accepted_state|
          result = render_inline described_class.new([degree], application_choice_state: accepted_state)
          expect(result.text).to include 'Institution'
          expect(result.text).to include 'The University of Oxford'
        end
      end

      it 'is not visible when the application_choice state is not one of the ACCEPTED_STATES' do
        (ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER - ApplicationStateChange::ACCEPTED_STATES).each do |state|
          result = render_inline described_class.new([degree], application_choice_state: state)
          expect(result.text).to include 'Institution'
          expect(result.text).not_to include 'The University of Oxford'
          expect(result.text).to include 'Institution name is withheld at this stage to avoid any unconscious bias in favour of certain institutions.'
        end
      end
    end
  end

  describe 'rendering multiple degrees' do
    let(:degree_1) { create(:degree_qualification) }
    let(:degree_2) { create(:degree_qualification) }

    it 'renders multiple cards containing degree details' do
      result = render_inline described_class.new([degree_1, degree_2])

      cards = result.css('.app-card--outline').each
      first_card = cards.next
      second_card = cards.next
      expect(first_card.text).to include degree_1.subject
      expect(first_card.text).to include degree_1.grade
      expect(second_card.text).to include degree_2.subject
      expect(second_card.text).to include degree_2.grade
    end
  end
end
