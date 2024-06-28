class App
  FILES_DIRECTORY = 'files/pages'.freeze

  def initialize(directory = FILES_DIRECTORY)
    @directory = directory
  end

  def run_script
    Dir.glob(File.join(@directory, '*.json')).each do |file|
      json_data = JSON.parse(File.read(file))
      tables = json_data.select { |block| block['BlockType'] == 'TABLE' }

      tables.each_with_index do |table, index|
        rows = table['Children'].map do |child_id|
          cell = json_data.detect { |block| block['Id'] == child_id }
          next unless cell

          row = cell['CellLocation']['R'] - 1
          text = cell['Children'].map { |child_id| json_data.detect { |block| block['Id'] == child_id }['Text'] }.join(' ')
          { row: row, text: text }
        end.compact

        puts "\n\n\n"
        puts "Page: #{table['Page']} -- Table: #{index + 1} of #{tables.size}"

        rows.group_by { |row| row[:row] }.each do |_, row_cells|
          formatted_row = row_cells.map { |cell| format_text(cell[:text]) }.join(',')
          puts formatted_row
        end
      end
    end
  end

  private

  def format_text(text)
    text.include?(',') ? "\"#{text}\"" : text
  end
end
