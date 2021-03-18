class HesaQualificationFieldsPresenter
  HESA_MAPPING = {
    hesa_degtype: { attr: :qualification_type_hesa_code, pad_to: 3 },
    hesa_degsbj: { attr: :subject_hesa_code, pad_to: nil },
    hesa_degclss: { attr: :grade_hesa_code, pad_to: 2 },
    hesa_degest: { attr: :institution_hesa_code, pad_to: 4 },
    hesa_degctry: { attr: :institution_country, pad_to: nil },
    hesa_degstdt: { attr: :start_year, pad_to: :iso8601 },
    hesa_degenddt: { attr: :award_year, pad_to: :iso8601 },
  }.freeze

  def initialize(qualification)
    @qualification = qualification
  end

  def to_hash
    if @qualification.level == 'degree'
      HESA_MAPPING.keys.index_with do |k|
        pad_to = HESA_MAPPING[k][:pad_to]
        value = @qualification.send(HESA_MAPPING[k][:attr])
        case pad_to
        when :iso8601 then "#{value}-01-01"
        when nil then value&.to_s
        else
          value&.to_s&.rjust(pad_to, '0')
        end
      end
    else
      HESA_MAPPING.keys.index_with { nil }
    end
  end
end
