module DataMigrations
  class UseReferenceDataForNationalities
    TIMESTAMP = 20251219172054
    MANUAL_RUN = false

    OLD_NATIONALITY_LIST = [
      ['AL', 'Albanian'],
      ['AF', 'Afghan'],
      ['DZ', 'Algerian'],
      ['US', 'American'],
      ['AD', 'Andorran'],
      ['AO', 'Angolan'],
      ['AI', 'Anguillan'],
      ['AR', 'Argentine'],
      ['AM', 'Armenian'],
      ['AU', 'Australian'],
      ['AT', 'Austrian'],
      ['AZ', 'Azerbaijani'],
      ['BS', 'Bahamian'],
      ['BH', 'Bahraini'],
      ['BD', 'Bangladeshi'],
      ['BB', 'Barbadian'],
      ['BY', 'Belarusian'],
      ['BE', 'Belgian'],
      ['BZ', 'Belizean'],
      ['BJ', 'Beninese'],
      ['BM', 'Bermudian'],
      ['BT', 'Bhutanese'],
      ['BO', 'Bolivian'],
      ['BW', 'Botswanan'],
      ['BR', 'Brazilian'],
      ['GB', 'British'],
      ['VG', 'British Virgin Islander'],
      ['BN', 'Bruneian'],
      ['BG', 'Bulgarian'],
      ['BF', 'Burkinan'],
      ['MM', 'Burmese'],
      ['BI', 'Burundian'],
      ['KH', 'Cambodian'],
      ['CM', 'Cameroonian'],
      ['CA', 'Canadian'],
      ['CV', 'Cape Verdean'],
      ['KY', 'Cayman Islander'],
      ['CF', 'Central African'],
      ['TD', 'Chadian'],
      ['CL', 'Chilean'],
      ['CN', 'Chinese'],
      ['AG', 'Citizen of Antigua and Barbuda'],
      ['BA', 'Citizen of Bosnia and Herzegovina'],
      ['GW', 'Citizen of Guinea-Bissau'],
      ['KI', 'Citizen of Kiribati'],
      ['SC', 'Citizen of Seychelles'],
      ['DO', 'Citizen of the Dominican Republic'],
      ['VU', 'Citizen of Vanuatu'],
      ['CO', 'Colombian'],
      ['KM', 'Comoran'],
      ['CG', 'Congolese (Congo)'],
      ['CD', 'Congolese (DRC)'],
      ['CK', 'Cook Islander'],
      ['CR', 'Costa Rican'],
      ['HR', 'Croatian'],
      ['CU', 'Cuban'],
      ['CY', 'Cypriot'],
      ['GB', 'Cymraes'],
      ['GB', 'Cymro'],
      ['CZ', 'Czech'],
      ['DK', 'Danish'],
      ['DJ', 'Djiboutian'],
      ['DM', 'Dominican'],
      ['NL', 'Dutch'],
      ['TL', 'East Timorese'],
      ['EC', 'Ecuadorean'],
      ['EG', 'Egyptian'],
      ['AE', 'Emirati'],
      ['GB', 'English'],
      ['GQ', 'Equatorial Guinean'],
      ['ER', 'Eritrean'],
      ['EE', 'Estonian'],
      ['ET', 'Ethiopian'],
      ['FO', 'Faroese'],
      ['FJ', 'Fijian'],
      ['PH', 'Filipino'],
      ['FI', 'Finnish'],
      ['FR', 'French'],
      ['GA', 'Gabonese'],
      ['GM', 'Gambian'],
      ['GE', 'Georgian'],
      ['DE', 'German'],
      ['GH', 'Ghanaian'],
      ['GI', 'Gibraltarian'],
      ['GR', 'Greek'],
      ['GL', 'Greenlandic'],
      ['GD', 'Grenadian'],
      ['GU', 'Guamanian'],
      ['GT', 'Guatemalan'],
      ['GN', 'Guinean'],
      ['GY', 'Guyanese'],
      ['HT', 'Haitian'],
      ['HN', 'Honduran'],
      ['HK', 'Hong Konger'],
      ['HU', 'Hungarian'],
      ['IS', 'Icelandic'],
      ['IN', 'Indian'],
      ['ID', 'Indonesian'],
      ['IR', 'Iranian'],
      ['IQ', 'Iraqi'],
      ['IE', 'Irish'],
      ['IL', 'Israeli'],
      ['IT', 'Italian'],
      ['CI', 'Ivorian'],
      ['JM', 'Jamaican'],
      ['JP', 'Japanese'],
      ['JO', 'Jordanian'],
      ['KZ', 'Kazakh'],
      ['KE', 'Kenyan'],
      ['KN', 'Kittitian'],
      ['XK', 'Kosovan'],
      ['KW', 'Kuwaiti'],
      ['KG', 'Kyrgyz'],
      ['LA', 'Lao'],
      ['LV', 'Latvian'],
      ['LB', 'Lebanese'],
      ['LR', 'Liberian'],
      ['LY', 'Libyan'],
      ['LI', 'Liechtenstein citizen'],
      ['LT', 'Lithuanian'],
      ['LU', 'Luxembourger'],
      ['MO', 'Macanese'],
      ['MK', 'Macedonian'],
      ['MG', 'Malagasy'],
      ['MW', 'Malawian'],
      ['MY', 'Malaysian'],
      ['MV', 'Maldivian'],
      ['ML', 'Malian'],
      ['MT', 'Maltese'],
      ['MH', 'Marshallese'],
      ['MQ', 'Martiniquais'],
      ['MR', 'Mauritanian'],
      ['MU', 'Mauritian'],
      ['MX', 'Mexican'],
      ['FM', 'Micronesian'],
      ['MD', 'Moldovan'],
      ['MC', 'Monegasque'],
      ['MN', 'Mongolian'],
      ['ME', 'Montenegrin'],
      ['MS', 'Montserratian'],
      ['MA', 'Moroccan'],
      ['LS', 'Mosotho'],
      ['MZ', 'Mozambican'],
      ['NA', 'Namibian'],
      ['NR', 'Nauruan'],
      ['NP', 'Nepalese'],
      ['NZ', 'New Zealander'],
      ['NI', 'Nicaraguan'],
      ['NG', 'Nigerian'],
      ['NE', 'Nigerien'],
      ['NU', 'Niuean'],
      ['KP', 'North Korean'],
      ['GB', 'Northern Irish'],
      ['NO', 'Norwegian'],
      ['OM', 'Omani'],
      ['PK', 'Pakistani'],
      ['PW', 'Palauan'],
      ['PS', 'Palestinian'],
      ['PA', 'Panamanian'],
      ['PG', 'Papua New Guinean'],
      ['PY', 'Paraguayan'],
      ['PE', 'Peruvian'],
      ['PN', 'Pitcairn Islander'],
      ['PL', 'Polish'],
      ['PT', 'Portuguese'],
      ['GB', 'Prydeinig'],
      ['PR', 'Puerto Rican'],
      ['QA', 'Qatari'],
      ['RO', 'Romanian'],
      ['RU', 'Russian'],
      ['RW', 'Rwandan'],
      ['SV', 'Salvadorean'],
      ['SM', 'Sammarinese'],
      ['WS', 'Samoan'],
      ['ST', 'Sao Tomean'],
      ['SA', 'Saudi Arabian'],
      ['GB', 'Scottish'],
      ['SN', 'Senegalese'],
      ['RS', 'Serbian'],
      ['SL', 'Sierra Leonean'],
      ['SG', 'Singaporean'],
      ['SK', 'Slovak'],
      ['SI', 'Slovenian'],
      ['SB', 'Solomon Islander'],
      ['SO', 'Somali'],
      ['ZA', 'South African'],
      ['KR', 'South Korean'],
      ['SS', 'South Sudanese'],
      ['ES', 'Spanish'],
      ['LK', 'Sri Lankan'],
      ['SH', 'St Helenian'],
      ['LC', 'St Lucian'],
      ['SD', 'Sudanese'],
      ['SR', 'Surinamese'],
      ['SZ', 'Swazi'],
      ['SE', 'Swedish'],
      ['CH', 'Swiss'],
      ['SY', 'Syrian'],
      ['TW', 'Taiwanese'],
      ['TJ', 'Tajik'],
      ['TZ', 'Tanzanian'],
      ['TH', 'Thai'],
      ['TG', 'Togolese'],
      ['TO', 'Tongan'],
      ['TT', 'Trinidadian'],
      ['SH', 'Tristanian'],
      ['TN', 'Tunisian'],
      ['TR', 'Turkish'],
      ['TM', 'Turkmen'],
      ['TC', 'Turks and Caicos Islander'],
      ['TV', 'Tuvaluan'],
      ['UG', 'Ugandan'],
      ['UA', 'Ukrainian'],
      ['UY', 'Uruguayan'],
      ['UZ', 'Uzbek'],
      ['VA', 'Vatican citizen'],
      ['VE', 'Venezuelan'],
      ['VN', 'Vietnamese'],
      ['VC', 'Vincentian'],
      ['WF', 'Wallisian'],
      ['GB', 'Welsh'],
      ['YE', 'Yemeni'],
      ['ZM', 'Zambian'],
      ['ZW', 'Zimbabwean'],
    ].to_h

    def change
      nationalities_to_update.each do |code, new_nationality|
        old_nationality = OLD_NATIONALITY_LIST[code]
        next if old_nationality.nil?

        columns.each do |col|
          to_update = current_forms.where(col => old_nationality)
          next if to_update.empty?

          to_update.update_all(col => new_nationality)
        end
      end
    end

  private

    def nationalities_to_update
      # There are 14 nationalities to update as of 19 Dec.
      @nationalities_to_update ||= NATIONALITIES.filter do |code, new_nationality|
        old_nationality = OLD_NATIONALITY_LIST[code]
        code != 'GB' && # Ignore British
          old_nationality.present? && # Ignore where there wasn't an old formation of the nationality
          new_nationality != old_nationality # eg "Turk, Turkish" != "Turkish"
      end
    end

    def current_forms
      @current_forms ||= ApplicationForm.where(recruitment_cycle_year: 2026)
    end

    def columns
      # There are no instances of the nationalities that need to be updated being stored in the
      # third, fourth or fifth nationality columns in 2025.
      %i[first_nationality second_nationality]
    end
  end
end

# The current nationalities that have a different citizen name than was used in the past as of 22/Dec

# [["BM", "Bermudan"], 2
#  ["KY", "Cayman Islander, Caymanian"], 3
#  ["CG", "Congolese (Republic of the Congo)"], 1
#  ["HK", "Hongkonger or Cantonese"], 67
#  ["LS", "Citizen of Lesotho"], 1
#  ["MG", "Citizen of Madagascar"], 1
#  ["MM", "Citizen of Myanmar"], 8
#  ["PN", "Pitcairn Islander or Pitcairner"], 0
#  ["SM", "San Marinese"], 0
#  ["SH", "St Helenian or Tristanian as appropriate. Ascension has no indigenous population"], 0
#  ["KN", "Citizen of St Christopher (St Kitts) and Nevis"], 0
#  ["TT", "Trinidad and Tobago citizen"], 10
#  ["TR", "Turk, Turkish"], 76
#  ["AE", "Citizen of the United Arab Emirates"]] 0
