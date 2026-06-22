require 'minitest/autorun'
require 'csv'

class TestCardData < Minitest::Test
  def setup
    @data = CSV.read('card_data_front_sides.csv', headers: true, col_sep: ';',
                     encoding: 'bom|utf-8')
                .reject { |row| row['ScenarioNumber'].nil? }
  end

  def test_csv_hat_eintraege
    assert @data.size > 0, "CSV enthält keine Zeilen"
  end

  def test_pflichtfelder_vorhanden
    @data.each_with_index do |row, i|
      zeile = "Zeile #{i + 2}"
      assert row['ScenarioNumber'],                                  "#{zeile}: ScenarioNumber fehlt"
      assert row['ScenarioNameDE'] && !row['ScenarioNameDE'].empty?, "#{zeile}: ScenarioNameDE fehlt"
      assert row['ScenarioImage']  && !row['ScenarioImage'].empty?,  "#{zeile}: ScenarioImage fehlt"
      # RoleNameDE darf leer sein (Manager-Karten haben keine Rolle)
    end
  end

  def test_hintergrundbilder_existieren
    @data.each_with_index do |row, i|
      bild = "images/#{row['ScenarioImage']}"
      assert File.exist?(bild), "Zeile #{i + 2}: Bild nicht gefunden → #{bild}"
    end
  end

  def test_szenario_nummern_sind_numerisch
    @data.each_with_index do |row, i|
      assert row['ScenarioNumber'].match?(/\A\d+\z/),
             "Zeile #{i + 2}: ScenarioNumber '#{row['ScenarioNumber']}' ist nicht numerisch"
    end
  end

  def test_regulaere_szenarien_haben_mindestens_eine_rolle
    regulaere = @data.reject { |row| row['RoleNameDE'].nil? || row['RoleNameDE'].empty? }
    assert regulaere.size > 0, "Keine regulären Rollen-Karten gefunden"
  end

  def test_manager_karten_haben_keine_rollenbox
    @data.select { |row| row['ScenarioNumber'] == '99' }.each_with_index do |row, i|
      role = row['RoleNameDE'] || ''
      assert role.empty?,
             "Manager-Karte #{i + 1}: RoleNameDE sollte leer sein (keine Rollenbox), ist aber '#{role}'"
    end
  end

  def test_skript_laeuft_ohne_fehler_und_warnungen
    output = `#{RbConfig.ruby} card_generator.rb 2>&1`
    assert $?.success?, "card_generator.rb endete mit Fehler:\n#{output}"
    refute_match(/WARN/i,  output, "card_generator.rb gab Warnungen aus:\n#{output}")
    refute_match(/error/i, output, "card_generator.rb gab Fehler aus:\n#{output}")
  end
end
