require 'squib'
require 'csv'

PAGE_W        = 2480
PAGE_H        = 3508
CARD_W        = 1050
CARD_H        =  750
GRID_COLS_NORMAL  =  2  # columns at full scale
GRID_COLS_COMPACT =  3  # columns when scaling down
COL_MARGIN        = 115  # left/right page margin
COL_GAP_BASE      = 150  # horizontal gap between columns at full scale (2 cols)
COL_GAP_COMPACT   =  60  # horizontal gap between columns in compact layout (3 cols)
ROW_TOP           = 220  # top of first card row (below title)
ROW_GAP_BASE      =  76  # vertical gap between rows at full scale
BOTTOM_MARGIN     =  60

# Base layout offsets within a card (must match layout.yml values)
BOX_Y_OFF         =  40   # y offset of header boxes from card top
NUMBER_BOX_X_OFF  =  40   # x offset of scenario number box
NUMBER_BOX_W      =  60
NUMBER_BOX_H      =  60
NAME_BOX_X_OFF    = 110   # x offset of scenario name box
NAME_BOX_W        = 900
NAME_BOX_H        =  60
NAME_TEXT_X_OFF   = 120
NAME_TEXT_Y_OFF   =  44   # absolute y within card (layout.yml: y: 44)
NAME_TEXT_W       = 880
NAME_TEXT_H       =  52

FONT_NUMBER = 10   # Courier New (must match layout.yml scenario_number_text)
FONT_NAME   = 13   # Courier New Bold (must match layout.yml scenario_name_text)

# Compute the scale factor so all scenarios fit on one page with the given column count.
# scale <= 1.0; cards are never enlarged.
def compute_scale(num_scenarios, cols)
  col_gap  = cols == GRID_COLS_COMPACT ? COL_GAP_COMPACT : COL_GAP_BASE
  num_rows = (num_scenarios / cols.to_f).ceil
  avail_w  = (PAGE_W - 2 * COL_MARGIN - (cols - 1) * col_gap) / cols.to_f
  avail_h  = (PAGE_H - ROW_TOP - BOTTOM_MARGIN - (num_rows - 1) * ROW_GAP_BASE) / num_rows.to_f
  [avail_w / CARD_W, avail_h / CARD_H, 1.0].min
end

# Use 2 columns at full scale; switch to 3 columns when scaling is needed,
# as 3 columns distribute the available space more efficiently.
def optimal_cols(num_scenarios)
  return GRID_COLS_NORMAL if compute_scale(num_scenarios, GRID_COLS_NORMAL) >= 1.0
  scale_normal  = compute_scale(num_scenarios, GRID_COLS_NORMAL)
  scale_compact = compute_scale(num_scenarios, GRID_COLS_COMPACT)
  scale_compact >= scale_normal ? GRID_COLS_COMPACT : GRID_COLS_NORMAL
end

def card_position(slot, cols, card_w, card_h, col_gap, row_gap)
  col = slot % cols
  row = slot / cols
  x   = COL_MARGIN + col * (card_w + col_gap)
  y   = ROW_TOP    + row * (card_h + row_gap)
  [x, y]
end

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

misc_data = CSV.read('card_data_back_sides_and_misc.csv', headers: true, col_sep: ';',
                     encoding: 'utf-8').each_with_object({}) do |row, h|
  h[row['Language']] = { overview_title: row['OverviewTitle'], game_name: row['GameName'] }
end

LANGUAGES.each do |lang|
  name_col = "ScenarioName#{lang}"
  misc     = misc_data[lang]
  abort "ERROR: No misc data for language '#{lang}' in card_data_back_sides_and_misc.csv" unless misc
  abort "ERROR: OverviewTitle missing for language '#{lang}'" if misc[:overview_title].nil? || misc[:overview_title].strip.empty?
  abort "ERROR: GameName missing for language '#{lang}'" if misc[:game_name].nil? || misc[:game_name].strip.empty?

  scenarios = front_data
    .reject  { |r| r['ScenarioNumber'] == '99' }
    .group_by { |r| r['ScenarioNumber'] }
    .values
    .map(&:first)

  game_prefix = misc[:game_name].gsub(' ', '_')
  out_file    = "#{game_prefix}_scenarios_#{lang}.pdf"
  out_path = "output/#{out_file}"
  begin
    File.delete(out_path) if File.exist?(out_path)
  rescue Errno::EACCES
    abort "ERROR: Cannot delete #{out_path} -- please close the file if it is open in a PDF viewer and try again."
  end

  cols         = optimal_cols(scenarios.size)
  scale        = compute_scale(scenarios.size, cols)
  card_w       = (CARD_W * scale).round
  card_h       = (CARD_H * scale).round
  col_gap_base = cols == GRID_COLS_COMPACT ? COL_GAP_COMPACT : COL_GAP_BASE
  col_gap      = (col_gap_base * scale).round
  num_rows = (scenarios.size / cols.to_f).ceil
  row_gap  = num_rows > 1 ?
    (PAGE_H - ROW_TOP - BOTTOM_MARGIN - num_rows * card_h) / (num_rows - 1) : 0

  sc = scale

  if scale < 1.0
    puts "#{lang}: #{scenarios.size} scenarios, #{cols} columns, #{num_rows} rows -- scaling cards to #{(scale * 100).round}% ..."
  else
    puts "#{lang}: rendering #{scenarios.size} scenarios on overview sheet ..."
  end

  Squib::Deck.new(cards: 1, width: PAGE_W, height: PAGE_H, layout: 'layout.yml') do
    background color: 'white'
    text layout: :overview_title, str: misc[:overview_title]

    scenarios.each_with_index do |row, i|
      cx, cy = card_position(i, cols, card_w, card_h, col_gap, row_gap)

      png file: "images/#{row['ScenarioImage']}",
          x: cx, y: cy, width: card_w, height: card_h

      rect layout: :scenario_number_box,
           x: cx + (NUMBER_BOX_X_OFF * sc).round, y: cy + (BOX_Y_OFF * sc).round,
           width: (NUMBER_BOX_W * sc).round,       height: (NUMBER_BOX_H * sc).round

      rect layout: :scenario_name_box,
           x: cx + (NAME_BOX_X_OFF * sc).round, y: cy + (BOX_Y_OFF * sc).round,
           width: (NAME_BOX_W * sc).round,       height: (NAME_BOX_H * sc).round

      text layout: :scenario_number_text,
           str:    row['ScenarioNumber'],
           x:      cx + (NUMBER_BOX_X_OFF * sc).round,
           y:      cy + (BOX_Y_OFF * sc).round,
           width:  (NUMBER_BOX_W * sc).round,
           height: (NUMBER_BOX_H * sc).round,
           font:   "Courier New #{[(FONT_NUMBER * sc).round, 6].max}"

      text layout: :scenario_name_text,
           str:    row[name_col],
           x:      cx + (NAME_TEXT_X_OFF * sc).round,
           y:      cy + (NAME_TEXT_Y_OFF * sc).round,
           width:  (NAME_TEXT_W * sc).round,
           height: (NAME_TEXT_H * sc).round,
           font:   "Courier New Bold #{[(FONT_NAME * sc).round, 6].max}"
    end

    save_pdf file: out_file, dir: 'output',
             width: '210mm', height: '297mm', margin: '0mm', gap: '0mm', trim: '0mm'
  end

  puts "#{lang}: scenario overview (#{scenarios.size} scenarios) -> output/#{out_file}"
end
