require 'rails_helper'

RSpec.describe ProviderInterface::WorkHistoryComponent do
  context 'with an empty history' do
    it 'renders nothing' do
      application_form = instance_double(ApplicationForm)
      allow(application_form).to receive(:application_work_experiences).and_return([])
      allow(application_form).to receive(:application_work_history_breaks).and_return([])

      rendered = render_inline(described_class, application_form: application_form)
      expect(rendered.text).to eq ''
    end
  end

  context 'with work experiences' do
    it 'renders nothing' do
      application_form = instance_double(ApplicationForm)
      experiences = [
        build(
          :application_work_experience,
          start_date: Date.new(2019, 10, 1),
          end_date: Date.new(2019, 12, 1),
        ),
        build(
          :application_work_experience,
          start_date: Date.new(2020, 1, 1),
        ),
      ]
      allow(application_form).to receive(:application_work_experiences).and_return(experiences)
      allow(application_form).to receive(:application_work_history_breaks).and_return([])

      rendered = render_inline(described_class, application_form: application_form)
      expect(rendered.text).to eq ''
    end
  end
end
