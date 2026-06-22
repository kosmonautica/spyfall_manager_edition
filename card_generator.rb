require 'squib'
require 'csv'

CARD_WIDTH  = 1050
CARD_HEIGHT = 750
PDF_OPTS    = { width: '210mm', height: '297mm', margin: '10mm', gap: '5mm', trim: '2mm' }

data = CSV.read('card_data_front_sides.csv', headers: true, col_sep: ';',
                encoding: 'bom|utf-8').reject { |row| row['ScenarioNumber'].nil? }

ROLE_BOX_MIN        = 200
ROLE_BOX_MAX        = 980
ROLE_BOX_PADDING    = 20
ROLE_BOX_H_ONE_LINE = 60
ROLE_BOX_H_TWO_LINE = 110
ROLE_CHARS_PER_LINE = 40

front_cards = data.map do |row|
  role = row['RoleNameDE'] || ''
  two_lines  = role.length > ROLE_CHARS_PER_LINE
  box_height = role.empty? ? 0 : (two_lines ? ROLE_BOX_H_TWO_LINE : ROLE_BOX_H_ONE_LINE)
  box_width  = role.empty? ? 0 : ROLE_BOX_MAX
  {
    scenario_number: row['ScenarioNumber'],
    scenario_name:   row['ScenarioNameDE'],
    role_name:       role,
    role_width:      box_width,
    role_height:     box_height,
    has_role:        !role.empty?,
    image:           "images/#{row['ScenarioImage']}"
  }
end

n = front_cards.size

%w[spyfall_manager_edition_frontsides.pdf spyfall_manager_edition_backsides.pdf].each do |f|
  path = "output/#{f}"
  File.delete(path) if File.exist?(path)
end

# Vorderseiten-PDF
Squib::Deck.new(cards: n, width: CARD_WIDTH, height: CARD_HEIGHT, layout: 'layout.yml') do
  png layout: :card_background,
      file: front_cards.map { |c| c[:image] }

  rect layout: :scenario_number_box
  rect layout: :scenario_name_box
  rect x: 20,
       y:      front_cards.map { |c| CARD_HEIGHT - 20 - c[:role_height] },
       width:  front_cards.map { |c| c[:role_width] },
       height: front_cards.map { |c| c[:role_height] },
       fill_color:   front_cards.map { |c| c[:has_role] ? '#c8a882' : '#00000000' },
       stroke_color: '#c8a882', stroke_width: 0, radius: 4

  text layout: :scenario_number_text,
       str: front_cards.map { |c| c[:scenario_number] }

  text layout: :scenario_name_text,
       str: front_cards.map { |c| c[:scenario_name] }

  text layout: :role_name_text,
       str:    front_cards.map { |c| c[:role_name] },
       y:      front_cards.map { |c| CARD_HEIGHT - 20 - c[:role_height] + 4 },
       width:  front_cards.map { |c| [c[:role_width] - ROLE_BOX_PADDING * 2, 0].max },
       height: front_cards.map { |c| [c[:role_height] - 8, 0].max }

  save_pdf file: 'spyfall_manager_edition_frontsides.pdf', dir: 'output', **PDF_OPTS
end

# Rückseiten-PDF
Squib::Deck.new(cards: n, width: CARD_WIDTH, height: CARD_HEIGHT, layout: 'layout.yml') do
  png layout: :card_background,
      file: 'images/backsideDE.png'
  save_pdf file: 'spyfall_manager_edition_backsides.pdf', dir: 'output', **PDF_OPTS
end

puts "Fertig! #{n} Karten → output/spyfall_manager_edition_frontsides.pdf + output/spyfall_manager_edition_backsides.pdf"
