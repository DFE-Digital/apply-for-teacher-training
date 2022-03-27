require 'rails_helper'

RSpec.describe CandidateInterface::DegreeEmptyComponent, type: :component do
  let(:application_form) { create(:application_form, :with_degree) }
  let(:component) { described_class.new(application_form: application_form) }

  describe '#render?' do
    context 'if application form has application qualifications at degree level' do
      it 'does not render' do
        expect(component.render?).to be_falsey
      end
    end

    context 'if application form has no application qualifications at degree level' do
      let(:application_form) { create(:application_form, :with_gcses) }

      it 'renders' do
        expect(component.render?).to be_truthy
      end
    end

    context 'if qualification_type is only foundation degrees' do
      it 'renders' do
        application_form.application_qualifications.first.update!(qualification_type: 'Foundation of Arts (FdA)')
        expect(component.render?).to be_truthy
      end
    end

    context 'if qualification type has a bachelor degree' do
      it 'does not render' do
        application_form.application_qualifications.first.update!(qualification_type: 'Bachelor of Arts (BA)')
        expect(component.render?).to be_falsey
      end
    end
  end

  describe 'button text' do
    context 'when only foundation degrees are present' do
      it 'renders add another degree' do
        application_form.application_qualifications.first.update!(qualification_type: 'Foundation of Arts (FdA)')
        result = render_inline(described_class.new(application_form: application_form))

        expect(result.css('.govuk-button').text).to eq('Add another degree')
      end
    end

    context 'when there are no degrees' do
      it 'renders add a degree' do
        application_form.application_qualifications.first.delete
        result = render_inline(described_class.new(application_form: application_form))

        expect(result.css('.govuk-button').text).to eq('Add a degree')
      end
    end
  end
end
