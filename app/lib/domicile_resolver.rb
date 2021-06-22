class DomicileResolver
  def self.hesa_code_for_country(iso_country_code)
    case iso_country_code
    when nil then 'ZZ'
    when 'AQ' then 'XX'
    when 'CY' then 'XC'
    when 'XK' then 'QO'
    else
      iso_country_code
    end
  end

  def self.hesa_code_for_postcode(uk_postcode)
    prefix = uk_postcode.scan(/^[a-zA-Z]+/).first if uk_postcode.present?

    case prefix
    when nil then 'ZZ'
    when *POSTCODE_PREFIXES['England'] then 'XF'
    when *POSTCODE_PREFIXES['Wales'] then 'XI'
    when *POSTCODE_PREFIXES['Scotland'] then 'XH'
    when *POSTCODE_PREFIXES['Northern Ireland'] then 'XG'
    when *POSTCODE_PREFIXES['Channel Islands'] then 'XL'
    else
      'XK'
    end
  end

  POSTCODE_PREFIXES = {
    'England' => %w[
      AL B BA BB BD BH BL BN BR BS CA CB CM CO CR CT CV CW DA DE DH DL DN DT DY
      E EC EN EX FY GL GU HA HD HG HP HU HX IG IP KT L LA LE LN LS LU M ME MK
      N NE NG NN NR NW OL OX PE PL PO PR RG RH RM S SE SG SK SL SM SN SO SP SR
      SS ST SW TA TF TN TQ TR TS TW UB W WA WC WD WF WN WR WS WV YO
    ],
    'Wales' => %w[CF SA],
    'Scotland' => %w[AB DD EH FK G HS IV KA KW KY ML PA PH ZE],
    'Northern Ireland' => %w[BT],
    'Channel Islands' => %w[GY JE],
    'Spanning Two Countries' => %w[CH DG HR LD LL NP SY TD],
  }.freeze
end
