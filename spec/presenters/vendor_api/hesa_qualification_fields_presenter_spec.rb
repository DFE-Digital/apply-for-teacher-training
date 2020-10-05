require 'rails_helper'

RSpec.describe VendorAPI::HesaQualificationFieldsPresenter do
  describe '#to_hash' do
    let(:qualification) { create(:degree_qualification) }
    let(:presenter) { VendorAPI::HesaQualificationFieldsPresenter.new(qualification) }

    direct_mapping_fields = {
      hesa_degtype: :qualification_type_hesa_code,
      hesa_degsbj: :subject_hesa_code,
      hesa_degclss: :grade_hesa_code,
      hesa_degest: :institution_hesa_code,
      hesa_degctry: :institution_country,
    }

    direct_mapping_fields.each do |hesa_field, our_field|
      it "#{hesa_field} is #{our_field}" do
        expect(presenter.to_hash[hesa_field]).to eq(qualification.send(our_field))
      end
    end

    it 'hesa_degstdt is start_year in ISO8601 format' do
      expect(presenter.to_hash[:hesa_degstdt]).to eq("#{qualification.start_year}-01-01")
    end

    it 'hesa_degenddt is award_year in ISO8601 format' do
      expect(presenter.to_hash[:hesa_degenddt]).to eq("#{qualification.award_year}-01-01")
    end

    it 'returns an empty hash for non-degree qualifications' do
      non_degree = create(:gcse_qualification)
      presenter = VendorAPI::HesaQualificationFieldsPresenter.new(non_degree)
      expect(presenter.to_hash).to eq({})
    end
  end
end
