require 'rails_helper'

RSpec.describe ApiDocs::ApiSchema do
  describe '#object_schema_name' do
    let :schema do
      @document = Openapi3Parser.load_file('config/vendor-api-v1.yml')
      schema_name, raw_schema = @document.components.schemas.find { |schema_name, _schema| schema_name == 'ApplicationAttributes' }
      ApiDocs::ApiSchema.new(name: schema_name, schema: raw_schema)
    end

    it 'finds the object_schema_name specified with $ref' do
      offer_property = schema.properties.find { |property| property.name == 'candidate' }

      expect(offer_property.object_schema_name).to eql('Candidate')
    end

    it 'finds the object_schema_name specified in an anyOf element' do
      offer_property = schema.properties.find { |property| property.name == 'offer' }

      expect(offer_property.object_schema_name).to eql('Offer')
    end
  end
end
