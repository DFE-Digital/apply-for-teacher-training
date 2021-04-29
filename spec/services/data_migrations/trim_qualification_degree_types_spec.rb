require 'rails_helper'

RSpec.describe DataMigrations::TrimQualificationDegreeTypes do
  it 'removes leading whitespace' do
    degree_qualification = create(:degree_qualification, qualification_type: '  Bachelor of Life')
    described_class.new.change
    expect(degree_qualification.reload.qualification_type).to eq 'Bachelor of Life'
  end

  it 'removes trailing whitespace' do
    degree_qualification = create(:degree_qualification, qualification_type: 'Bachelor of Life   ')
    described_class.new.change
    expect(degree_qualification.reload.qualification_type).to eq 'Bachelor of Life'
  end

  it 'leaves values without any leading/trailing whitespace as they are' do
    degree_qualification = create(:degree_qualification, qualification_type: 'Bachelor of Life')
    described_class.new.change
    expect(degree_qualification.reload.qualification_type).to eq 'Bachelor of Life'
  end
end
