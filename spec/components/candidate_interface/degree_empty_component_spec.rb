require 'rails_helper'

RSpec.describe CandidateInterface::DegreeEmptyComponent, type: :component do
  let(:application_form) { create(:application_form, :with_degree) }
  let(:component) { described_class.new(application_form:) }

  describe '#render?' do
    context 'if application form has no application qualifications at degree level' do
      let(:application_form) { create(:application_form, :with_gcses) }

      it 'renders' do
        expect(component.render?).to be_truthy
      end
    end

    context 'if qualification type is only foundation degrees' do
      it 'renders' do
        application_form.application_qualifications.first.update!(qualification_type: 'Foundation of Arts')
        expect(component.render?).to be_truthy
      end
    end

    context 'if qualification type is not a foundation degree' do
      it 'does not render' do
        application_form.application_qualifications.first.update!(qualification_type: 'Bachelor of Arts')
        expect(component.render?).to be_falsey
      end
    end
  end

  describe 'when teacher degree apprenticeship feature is on' do
    subject(:result) { render_inline(described_class.new(application_form:)).text }

    let(:application_form) { create(:application_form, recruitment_cycle_year: 2025) }

    before do
      FeatureFlag.activate(:teacher_degree_apprenticeship)
    end

    it 'renders degree types headers' do
      expect(result).to include('Postgraduate teacher training courses')
      expect(result).to include('Teacher degree apprenticeships')
    end
  end

  describe 'when teacher degree apprenticeship feature is off' do
    subject(:result) { render_inline(described_class.new(application_form:)).text }

    let(:application_form) { create(:application_form, recruitment_cycle_year: 2024) }

    before do
      FeatureFlag.deactivate(:teacher_degree_apprenticeship)
    end

    it 'does not render degree types headers' do
      expect(result).not_to include('Postgraduate teacher training courses')
      expect(result).not_to include('Teacher degree apprenticeships')
    end
  end

  describe 'button text' do
    context 'when only foundation degrees are present' do
      it 'renders add another degree' do
        application_form.application_qualifications.first.update!(qualification_type: 'Foundation of Arts')
        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-button').text).to eq('Add another degree')
      end
    end

    context 'when there are no degrees' do
      it 'renders add a degree' do
        application_form.application_qualifications.first.delete
        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-button').text).to eq('Add a degree')
      end
    end
  end
end
