require 'minitest/autorun'
require 'csv'

class TestScenarioOverview < Minitest::Test
  def setup
    @misc = CSV.read('card_data_back_sides_and_misc.csv', headers: true, col_sep: ';',
                     encoding: 'utf-8')
               .reject { |row| row['Language'].nil? }
  end

  # --- CSV ---

  def test_overview_title_vorhanden_fuer_de_und_en
    sprachen = @misc.map { |row| row['Language'] }
    assert_includes sprachen, 'DE', "card_data_back_sides_and_misc.csv: OverviewTitle-Eintrag für DE fehlt"
    assert_includes sprachen, 'EN', "card_data_back_sides_and_misc.csv: OverviewTitle-Eintrag für EN fehlt"
  end

  def test_overview_title_nicht_leer
    @misc.each_with_index do |row, i|
      zeile = "Zeile #{i + 2} (#{row['Language']})"
      assert row['OverviewTitle'] && !row['OverviewTitle'].strip.empty?,
             "#{zeile}: OverviewTitle fehlt oder ist leer"
    end
  end

  def test_game_name_vorhanden_und_nicht_leer
    @misc.each_with_index do |row, i|
      zeile = "Zeile #{i + 2} (#{row['Language']})"
      assert row['GameName'] && !row['GameName'].strip.empty?,
             "#{zeile}: GameName fehlt oder ist leer"
    end
  end

  # --- Script ---

  def test_skript_laeuft_ohne_fehler_und_warnungen
    output = `#{RbConfig.ruby} scenario_overview.rb DE 2>&1`
    assert $?.success?, "scenario_overview.rb endete mit Fehler:\n#{output}"
    refute_match(/WARN/i,  output, "scenario_overview.rb gab Warnungen aus:\n#{output}")
    refute_match(/error/i, output, "scenario_overview.rb gab Fehler aus:\n#{output}")
  end

  def test_output_dateiname_stimmt_mit_game_name_ueberein
    `#{RbConfig.ruby} scenario_overview.rb DE 2>&1`
    return unless $?.success?
    prefix = @misc.find { |r| r['Language'] == 'DE' }&.[]('GameName')&.gsub(' ', '_')
    skip "GameName für DE nicht gesetzt" unless prefix
    assert File.exist?("output/#{prefix}_scenarios_DE.pdf"),
           "Scenarios-PDF nicht gefunden -- GameName '#{prefix}' stimmt nicht mit Dateiname überein"
  end

  def test_dreispaltig_wenn_skalierung_noetig
    front = CSV.read('card_data_front_sides.csv', headers: true, col_sep: ';', encoding: 'bom|utf-8')
               .reject { |r| r['ScenarioNumber'].nil? }
    scenario_count = front.reject { |r| r['ScenarioNumber'] == '99' }
                          .group_by { |r| r['ScenarioNumber'] }.size
    output = `#{RbConfig.ruby} scenario_overview.rb DE 2>&1`

    # At full scale (2 cols x 4 rows = 8 slots), no scaling is needed
    if scenario_count > 8
      assert_match(/3 columns/, output,
                   "Mit #{scenario_count} Szenarien sollte das Übersichtsblatt 3 Spalten verwenden")
    else
      refute_match(/scaling/, output,
                   "Mit #{scenario_count} Szenarien sollte keine Skalierung nötig sein")
    end
  end

  # --- Output ---

  PDFTK = 'C:\Program Files (x86)\PDFtk\bin\pdftk.exe'.freeze

  def pdf_page_count(path)
    skip "PDFtk nicht gefunden -- Seitenanzahl-Test übersprungen" unless File.exist?(PDFTK)
    output = `"#{PDFTK}" "#{path}" dump_data 2>&1`
    output.match(/NumberOfPages:\s*(\d+)/i)&.[](1)&.to_i
  end

  def test_overview_pdf_hat_genau_eine_seite
    ['DE', 'EN'].each do |lang|
      prefix = @misc.find { |r| r['Language'] == lang }&.[]('GameName')&.gsub(' ', '_')
      skip "GameName für #{lang} nicht gesetzt -- PDF-Test übersprungen" unless prefix
      path = "output/#{prefix}_scenarios_#{lang}.pdf"
      skip "PDF für #{lang} noch nicht generiert" unless File.exist?(path)
      actual_pages = pdf_page_count(path)
      assert_equal 1, actual_pages,
                   "#{lang}: Übersichts-PDF muss immer genau 1 Seite haben (hat #{actual_pages}) -- alle Szenarien müssen ohne Blättern sichtbar sein"
    end
  end
end
