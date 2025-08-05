require 'rails_helper'

RSpec.describe ProviderInterface::QualificationsComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:application_choice) { nil }
  let(:application_form) { create(:application_form, :completed, :with_bachelor_degree) }
  let(:component) do
    described_class.new(
      application_form: application_form,
      application_choice: application_choice,
    )
  end

  subject(:result) { render_inline(component) }

  context 'when application choice is postgreaduate course' do
    let(:application_choice) { create(:application_choice, application_form:) }

    it 'renders degrees information' do
      expect(result.text).to include(application_form.application_qualifications.degrees.first.subject)
    end

    it 'does not include HESA codes' do
      expect(result.text).not_to include('HESA codes')
    end

    it 'does not include change links' do
      expect(result).to have_no_link('Change', href: support_interface_application_form_edit_degree_path(application_form, application_form.application_qualifications.degrees.first))
    end
  end

  context 'when application choice is teacher degree apprenticeship course' do
    let(:teacher_degree_apprenticeship_course) { create(:course, :teacher_degree_apprenticeship, :open) }
    let(:application_choice) { create(:application_choice, application_form:, course_option: create(:course_option, course: teacher_degree_apprenticeship_course)) }

    it 'renders no degree required content message' do
      expect(result.text).to include(I18n.t('provider_interface.degree.teacher_degree_apprenticeship_message'))
    end

    it 'does not render degree information' do
      expect(result.text).not_to include(application_form.application_qualifications.degrees.first.subject)
    end
  end
end
