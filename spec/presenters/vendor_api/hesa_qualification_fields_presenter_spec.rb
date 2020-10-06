require 'rails_helper'

RSpec.describe VendorAPI::HesaQualificationFieldsPresenter do
  describe '#to_hash' do
    let(:qualification) { create(:degree_qualification) }
    let(:presenter) { VendorAPI::HesaQualificationFieldsPresenter.new(qualification) }

    direct_mappings = {
      hesa_degtype: { attr: :qualification_type_hesa_code, zeropad: 3 },
      hesa_degsbj: { attr: :subject_hesa_code, zeropad: 6 },
      hesa_degclss: { attr: :grade_hesa_code, zeropad: 2 },
      hesa_degest: { attr: :institution_hesa_code, zeropad: 4 },
      hesa_degctry: { attr: :institution_country, zeropad: 2 },
    }

    direct_mappings.each do |hesa_field, data|
      our_field = data[:attr]
      pad_to = data[:zeropad]

      it "#{hesa_field} is #{our_field} zero-padded to #{pad_to} chars" do
        expect(presenter.to_hash[hesa_field]).to eq(qualification.send(our_field)&.to_s.rjust(pad_to, '0'))
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
