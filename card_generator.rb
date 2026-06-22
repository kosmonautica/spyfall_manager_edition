require 'squib'
require 'csv'

CARD_WIDTH  = 1050
CARD_HEIGHT = 750
PDF_OPTS    = { width: '210mm', height: '297mm', margin: '10mm', gap: '5mm', trim: '2mm' }

ROLE_BOX_MIN        = 200
ROLE_BOX_MAX        = 980
ROLE_BOX_PADDING    = 20
ROLE_BOX_H_ONE_LINE = 60
ROLE_BOX_H_TWO_LINE = 110
ROLE_CHARS_PER_LINE = 40

lang_arg = (ARGV[0] || 'both').upcase
LANGUAGES = case lang_arg
            when 'DE'   then ['DE']
            when 'EN'   then ['EN']
            when 'BOTH' then ['DE', 'EN']
            else
              warn "Unknown language '#{ARGV[0]}' -- allowed values: DE, EN, both"
              exit 1
            end

front_data = CSV.read('card_data_front_sides.csv', headers: true, col_sep: ';',
                      encoding: 'bom|utf-8').reject { |row| row['ScenarioNumber'].nil? }

back_data = CSV.read('card_data_back_sides.csv', headers: true, col_sep: ';',
                     encoding: 'utf-8').each_with_object({}) do |row, h|
  h[row['Language']] = { text: row['BacksideText'], image: "images/#{row['BacksideImage']}" }
end

def build_front_cards(data, name_col, role_col)
  data.map do |row|
    role = row[role_col] || ''
    two_lines  = role.length > ROLE_CHARS_PER_LINE
    box_height = role.empty? ? 0 : (two_lines ? ROLE_BOX_H_TWO_LINE : ROLE_BOX_H_ONE_LINE)
    box_width  = role.empty? ? 0 : ROLE_BOX_MAX
    {
      scenario_number: row['ScenarioNumber'],
      scenario_name:   row[name_col],
      role_name:       role,
      role_width:      box_width,
      role_height:     box_height,
      has_role:        !role.empty?,
      image:           "images/#{row['ScenarioImage']}"
    }
  end
end

LANGUAGES.each do |lang|
  name_col = "ScenarioName#{lang}"
  role_col = "RoleName#{lang}"
  back     = back_data[lang]
  abort "ERROR: No backside data for language '#{lang}' in card_data_back_sides.csv" unless back
  abort "ERROR: Backside text missing for language '#{lang}'" if back[:text].nil? || back[:text].strip.empty?

  front_file = "spyfall_manager_edition_frontsides_#{lang}.pdf"
  back_file  = "spyfall_manager_edition_backsides_#{lang}.pdf"

  [front_file, back_file].each do |f|
    path = "output/#{f}"
    begin
      File.delete(path) if File.exist?(path)
    rescue Errno::EACCES
      abort "ERROR: Cannot delete #{path} -- please close the file if it is open in a PDF viewer and try again."
    end
  end

  cards = build_front_cards(front_data, name_col, role_col)
  n     = cards.size

  Squib::Deck.new(cards: n, width: CARD_WIDTH, height: CARD_HEIGHT, layout: 'layout.yml') do
    png layout: :card_background,
        file: cards.map { |c| c[:image] }

    rect layout: :scenario_number_box
    rect layout: :scenario_name_box
    rect x: 40,
         y:      cards.map { |c| CARD_HEIGHT - 40 - c[:role_height] },
         width:  cards.map { |c| c[:role_width] },
         height: cards.map { |c| c[:role_height] },
         fill_color:   cards.map { |c| c[:has_role] ? '#c8a882' : '#00000000' },
         stroke_color: '#c8a882', stroke_width: 0, radius: 4

    text layout: :scenario_number_text,
         str: cards.map { |c| c[:scenario_number] }

    text layout: :scenario_name_text,
         str: cards.map { |c| c[:scenario_name] }

    text layout: :role_name_text,
         str:    cards.map { |c| c[:role_name] },
         y:      cards.map { |c| CARD_HEIGHT - 40 - c[:role_height] + 4 },
         width:  cards.map { |c| [c[:role_width] - ROLE_BOX_PADDING * 2, 0].max },
         height: cards.map { |c| [c[:role_height] - 8, 0].max }

    save_pdf file: front_file, dir: 'output', **PDF_OPTS
  end

  # rtl: true mirrors the card layout horizontally so front and back sides
  # align correctly when printing duplex (flip on long edge)
  Squib::Deck.new(cards: n, width: CARD_WIDTH, height: CARD_HEIGHT, layout: 'layout.yml') do
    background color: 'white'
    text layout: :backside_text, str: back[:text]
    save_pdf file: back_file, dir: 'output', rtl: true, **PDF_OPTS
  end

  puts "#{lang}: #{n} cards -> output/#{front_file} + output/#{back_file}"
end
