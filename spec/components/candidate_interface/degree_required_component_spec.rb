require 'rails_helper'

RSpec.describe CandidateInterface::DegreeRequiredComponent, type: :component do
  let(:application_form) { create(:application_form) }

  let(:course_option1) { create(:course_option, course: create(:course, :open_on_apply, degree_grade: 'two_one')) }

  let(:application_choice) do
    build_stubbed(
      :application_choice,
      status: :unsubmitted,
      course_option: course_option1,
      application_form: application_form,
    )
  end

  context 'application has no degree and course has requirement' do
    it 'renders the degree row without guidance' do
      result = render_inline(described_class.new(application_choice))
      expect(result.text).to include('2:1 degree or higher (or equivalent)')
    end
  end

  context 'application has other degree and course has requirement' do
    it 'renders the degree row without guidance' do
      create(
        :degree_qualification,
        qualification_type: 'Other Qual',
        subject: 'Woof',
        institution_name: 'University of Doge',
        institution_country: 'GB',
        grade: 'Lower second-class honours (2:2)',
        predicted_grade: false,
        start_year: '2005',
        award_year: '2008',
        application_form: application_form,
      )

      result = render_inline(described_class.new(application_choice))
      expect(result.text).to include('2:1 degree or higher (or equivalent)')
    end
  end

  context 'application has non_uk degree' do
    it 'renders the degree row without guidance' do
      create(
        :degree_qualification,
        qualification_type: 'Bachelor of Arts',
        subject: 'Woof',
        institution_name: 'University of Doge',
        institution_country: 'Armenia',
        grade: 'Lower second-class honours (2:2)',
        predicted_grade: false,
        start_year: '2005',
        award_year: '2008',
        application_form: application_form,
      )

      result = render_inline(described_class.new(application_choice))
      expect(result.text).to include('2:1 degree or higher (or equivalent)')
    end
  end

  context 'application has degree with non standard type grade' do
    it 'renders the degree row without guidance' do
      create(
        :degree_qualification,
        qualification_type: 'Master of Arts',
        subject: 'Woof',
        institution_name: 'University of Doge',
        institution_country: nil,
        grade: 'Merit',
        predicted_grade: false,
        start_year: '2005',
        award_year: '2008',
        application_form: application_form,
      )

      result = render_inline(described_class.new(application_choice))
      expect(result.text).to include('2:1 degree or higher (or equivalent)')
    end
  end

  context 'application has degree at required level' do
    it 'renders the degree row without guidance' do
      create(
        :degree_qualification,
        qualification_type: 'Bachelor of Arts',
        subject: 'Woof',
        institution_name: 'University of Doge',
        institution_country: 'GB',
        grade: 'Upper second-class honours (2:1)',
        predicted_grade: false,
        start_year: '2005',
        award_year: '2008',
        application_form: application_form,
      )

      result = render_inline(described_class.new(application_choice))
      expect(result.text).to include('2:1 degree or higher (or equivalent)')
    end
  end

  context 'application has a degree with grade below required level' do
    it 'renders the degree row with guidance' do
      create(
        :degree_qualification,
        qualification_type: 'Bachelor of Arts',
        subject: 'Woof',
        institution_name: 'University of Doge',
        institution_country: 'GB',
        grade: 'Lower second-class honours (2:2)',
        predicted_grade: false,
        start_year: '2005',
        award_year: '2008',
        application_form: application_form,
      )
      result = render_inline(described_class.new(application_choice))
      expect(result.text).to include('2:1 degree or higher (or equivalent)')
      expect(result.text).to include('You said you have a 2:2 degree.')
      expect(result.text).to include('find a course that has a lower degree requirement')
      expect(result.text).to include('contact the provider to see if they will still consider your application')
    end
  end
end
