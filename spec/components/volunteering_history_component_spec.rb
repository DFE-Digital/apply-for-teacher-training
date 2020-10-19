require 'rails_helper'

RSpec.describe VolunteeringHistoryComponent do
  context 'with an empty history' do
    it 'renders nothing' do
      application_form = instance_double(ApplicationForm)
      allow(application_form).to receive(:application_volunteering_experiences).and_return([])

      rendered = render_inline(described_class.new(application_form: application_form))
      expect(rendered.text).to eq ''
    end
  end

  context 'with volunteering experiences' do
    it 'renders work, volunteering experience details and explained break' do
      application_form = instance_double(ApplicationForm)
      experiences = [
        build(
          :application_volunteering_experience,
          start_date: Date.new(2020, 1, 1),
          end_date: nil,
          role: 'Childrens entertainer',
          organisation: 'Clowns Unlimited',
          details: 'I performed magic tricks at parties',
          working_with_children: true,
          working_pattern: '3 hours per week',
        ),
        build(
          :application_volunteering_experience,
          start_date: Date.new(2018, 3, 1),
          end_date: Date.new(2018, 6, 30),
          role: 'Playgroup helper',
          organisation: 'Chigley Community Playgroup',
          details: 'I helped out a local Playgroup',
          working_with_children: true,
          working_pattern: '1 day per week',
        ),
      ]
      allow(application_form).to receive(:application_volunteering_experiences).and_return(experiences)

      rendered = render_inline(described_class.new(application_form: application_form))
      expect(rendered.text).to include 'March 2018 - June 2018'
      expect(rendered.text).to include 'Playgroup helper - 1 day per week'
      expect(rendered.text).to include 'Chigley Community Playgroup'
      expect(rendered.text).to include 'January 2020 - Present'
      expect(rendered.text).to include 'Childrens entertainer - 3 hours per week'
      expect(rendered.text).to include 'Clowns Unlimited'
    end
  end
end
