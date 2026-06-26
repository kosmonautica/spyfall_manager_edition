require 'minitest/autorun'
require 'csv'

class TestCardData < Minitest::Test
  def setup
    @front = CSV.read('card_data_front_sides.csv', headers: true, col_sep: ';',
                      encoding: 'bom|utf-8')
                .reject { |row| row['ScenarioNumber'].nil? }

    @back = CSV.read('card_data_back_sides_and_misc.csv', headers: true, col_sep: ';',
                     encoding: 'utf-8')
               .reject { |row| row['Language'].nil? }
  end

  # --- Front sides ---

  def test_csv_hat_eintraege
    assert @front.size > 0, "card_data_front_sides.csv enthält keine Zeilen"
  end

  def test_pflichtfelder_vorhanden
    @front.each_with_index do |row, i|
      zeile = "Zeile #{i + 2}"
      assert row['ScenarioNumber'],                                  "#{zeile}: ScenarioNumber fehlt"
      assert row['ScenarioNameDE'] && !row['ScenarioNameDE'].empty?, "#{zeile}: ScenarioNameDE fehlt"
      assert row['ScenarioNameEN'] && !row['ScenarioNameEN'].empty?, "#{zeile}: ScenarioNameEN fehlt"
      assert row['ScenarioImage']  && !row['ScenarioImage'].empty?,  "#{zeile}: ScenarioImage fehlt"
      # RoleNameDE/EN darf leer sein (Manager-Karten haben keine Rolle)
    end
  end

  def test_hintergrundbilder_existieren
    @front.each_with_index do |row, i|
      bild = "images/#{row['ScenarioImage']}"
      assert File.exist?(bild), "Zeile #{i + 2}: Bild nicht gefunden -> #{bild}"
    end
  end

  def test_szenario_nummern_sind_numerisch
    @front.each_with_index do |row, i|
      assert row['ScenarioNumber'].match?(/\A\d+\z/),
             "Zeile #{i + 2}: ScenarioNumber '#{row['ScenarioNumber']}' ist nicht numerisch"
    end
  end

  def test_regulaere_szenarien_haben_mindestens_eine_rolle
    regulaere = @front.reject { |row| row['RoleNameDE'].nil? || row['RoleNameDE'].empty? }
    assert regulaere.size > 0, "Keine regulären Rollen-Karten gefunden"
  end

  def test_manager_karten_haben_keine_rollenbox
    @front.select { |row| row['ScenarioNumber'] == '99' }.each_with_index do |row, i|
      role = row['RoleNameDE'] || ''
      assert role.empty?,
             "Manager-Karte #{i + 1}: RoleNameDE sollte leer sein, ist aber '#{role}'"
    end
  end

  # --- Back sides ---

  def test_rueckseiten_csv_hat_de_und_en
    sprachen = @back.map { |row| row['Language'] }
    assert_includes sprachen, 'DE', "card_data_back_sides.csv: Eintrag für DE fehlt"
    assert_includes sprachen, 'EN', "card_data_back_sides.csv: Eintrag für EN fehlt"
  end

  def test_rueckseiten_pflichtfelder_vorhanden
    @back.each_with_index do |row, i|
      zeile = "Zeile #{i + 2} (back_sides)"
      assert row['Language']     && !row['Language'].empty?,     "#{zeile}: Language fehlt"
      assert row['BacksideText'] && !row['BacksideText'].empty?, "#{zeile}: BacksideText fehlt"
    end
  end

  # --- Script ---

  def test_skript_laeuft_ohne_fehler_und_warnungen
    output = `#{RbConfig.ruby} card_generator.rb DE 2>&1`
    assert $?.success?, "card_generator.rb endete mit Fehler:\n#{output}"
    refute_match(/WARN/i,  output, "card_generator.rb gab Warnungen aus:\n#{output}")
    refute_match(/error/i, output, "card_generator.rb gab Fehler aus:\n#{output}")
  end

  PDFTK = 'C:\Program Files (x86)\PDFtk\bin\pdftk.exe'.freeze

  def pdf_page_count(path)
    skip "PDFtk nicht gefunden -- Seitenanzahl-Test übersprungen" unless File.exist?(PDFTK)
    output = `"#{PDFTK}" "#{path}" dump_data 2>&1`
    output.match(/NumberOfPages:\s*(\d+)/i)&.[](1)&.to_i
  end

  def test_vorder_und_rueckseiten_pdf_gleich_viele_seiten
    ['DE', 'EN'].each do |lang|
      front = "output/spyfall_manager_edition_frontsides_#{lang}.pdf"
      back  = "output/spyfall_manager_edition_backsides_#{lang}.pdf"
      skip "PDFs für #{lang} noch nicht generiert" unless File.exist?(front) && File.exist?(back)
      pages_front = pdf_page_count(front)
      pages_back  = pdf_page_count(back)
      assert_equal pages_front, pages_back,
                   "#{lang}: Frontsides hat #{pages_front} Seiten, Backsides hat #{pages_back} -- Duplex-Druck wäre versetzt!"
    end
  end
end
