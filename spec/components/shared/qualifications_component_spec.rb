require 'rails_helper'

RSpec.describe QualificationsComponent, type: :component do
  let(:application_form) { instance_double(ApplicationForm, editable?: true) }
  let(:application_choice) { instance_double(ApplicationChoice, status: 'accepted', teacher_degree_apprenticeship?: false) }
  let(:show_hesa_codes) { false }
  let(:component) { described_class.new(application_form: application_form, application_choice: application_choice, show_hesa_codes: show_hesa_codes) }

  describe '#editable?' do
    context 'when the form is editable and in support interface' do
      before do
        allow(component).to receive(:current_namespace).and_return('support_interface')
      end

      it 'returns true' do
        expect(component).to be_editable
      end
    end

    context 'when the form is not editable' do
      let(:application_form) { instance_double(ApplicationForm, editable?: false) }

      it 'returns false' do
        expect(component).not_to be_editable
      end
    end

    context 'when not in support interface' do
      before do
        allow(component).to receive(:current_namespace).and_return('provider_interface')
      end

      it 'returns false' do
        expect(component).not_to be_editable
      end
    end
  end

  describe '#render_degrees?' do
    context 'when in support interface' do
      before do
        allow(component).to receive(:current_namespace).and_return('support_interface')
      end

      it 'returns true' do
        expect(component.render_degrees?).to be true
      end
    end

    context 'when in provider interface and application_choice is present and not a teacher degree apprenticeship' do
      before do
        allow(component).to receive(:current_namespace).and_return('provider_interface')
      end

      it 'returns true' do
        expect(component.render_degrees?).to be true
      end
    end

    context 'when in provider interface and application_choice is nil' do
      let(:application_choice) { nil }

      before do
        allow(component).to receive(:current_namespace).and_return('provider_interface')
      end

      it 'returns false' do
        expect(component.render_degrees?).to be false
      end
    end

    context 'when in provider interface and application_choice is a teacher degree apprenticeship' do
      let(:application_choice) { instance_double(ApplicationChoice, status: 'accepted', teacher_degree_apprenticeship?: true) }

      before do
        allow(component).to receive(:current_namespace).and_return('provider_interface')
      end

      it 'returns false' do
        expect(component.render_degrees?).to be false
      end
    end
  end
end
