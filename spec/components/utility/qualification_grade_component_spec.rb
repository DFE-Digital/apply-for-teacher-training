require 'rails_helper'

RSpec.describe QualificationGradeComponent, type: :component do
  context 'given a degree' do
    let(:qualification) do
      build_stubbed(
        :degree_qualification,
        grade: 'First class honours',
      )
    end

    it 'correctly renders the grade' do
      result = render_inline(described_class.new(qualification: qualification))

      expect(result.text).to include('First class honours')
    end

    it 'correctly renders the HESA code if present' do
      qualification.grade_hesa_code = 1

      result = render_inline(described_class.new(qualification: qualification))

      expect(result.text).to include('First class honours')
      expect(result.text).to include('(1)')
    end
  end

  context 'given a GCSE' do
    let(:qualification) do
      build_stubbed(
        :gcse_qualification,
        grade: 'A*',
      )
    end

    it 'correctly renders the grade' do
      result = render_inline(described_class.new(qualification: qualification))

      expect(result.text).to include('A*')
    end
  end
end
