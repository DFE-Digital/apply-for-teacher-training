require 'rails_helper'

RSpec.describe QualificationSubjectComponent, type: :component do
  context 'given a degree' do
    let(:qualification) do
      build_stubbed(
        :application_qualification,
        level: :degree,
        qualification_type: 'BSc',
        subject: 'psychology',
      )
    end

    it 'correctly renders the subject' do
      result = render_inline(described_class.new(qualification: qualification))

      expect(result.text).to include('Psychology')
    end

    it 'correctly renders the HESA code if present' do
      qualification.subject_hesa_code = 22

      result = render_inline(described_class.new(qualification: qualification))

      expect(result.text).to include('Psychology')
      expect(result.text).to include('(22)')
    end
  end

  context 'given a GCSE' do
    let(:qualification) do
      build_stubbed(
        :gcse_qualification,
        subject: 'maths',
      )
    end

    it 'correctly renders the subject' do
      result = render_inline(described_class.new(qualification: qualification))

      expect(result.text).to include('Maths')
    end
  end
end
