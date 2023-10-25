require 'rails_helper'

RSpec.describe Section do
  describe '.all' do
    it 'returns all sections in an application' do
      expect(described_class.all.map(&:id)).to contain_exactly(
        :personal_details,
        :contact_details,
        :training_with_a_disability,
        :interview_preferences,
        :equality_and_diversity,
        :becoming_a_teacher,
        :science_gcse,
        :maths_gcse,
        :english_gcse,
        :efl,
        :references,
        :safeguarding_issues,
        :other_qualifications,
        :degrees,
        :volunteering,
        :work_history,
      )
    end
  end

  describe '.editable' do
    before do
      allow(Rails.configuration.x.sections)
        .to receive(:[])
        .with('editable')
        .and_return(%i[personal_details])
    end

    it 'returns all editable sections in configuration' do
      expect(described_class.editable.map(&:id)).to contain_exactly(:personal_details)
    end
  end

  describe '.non_editable' do
    before do
      allow(Rails.configuration.x.sections)
        .to receive(:[])
        .with('editable')
        .and_return(described_class.all.map(&:id) - %i[degrees])
    end

    it 'returns non editable sections' do
      expect(described_class.non_editable.map(&:id)).to contain_exactly(:degrees)
    end
  end
end
