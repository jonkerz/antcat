#  How to import a references file from Bolton
#  1) Open the file in Word
#  2) Save it as web page

class Bolton::Bibliography
  def initialize filename, show_progress = false
    Progress.init show_progress
    @filename = filename.to_s
  end

  def import_file
    Progress.print "Importing #{@filename}"
    import_html File.read(@filename)
    Progress.puts
  end

  def import_html html
    doc = Nokogiri::HTML html
    ps = doc.css('p')
    ps.each do |p|
      import_reference p.inner_html
    end
  end

  def import_reference string
    string = normalize string
    return unless string.length > 20

    string, date = extract_date string

    match = string.match /(\D+) ?(\d\w+)\.? ?(.+)[,.]/
    return unless match

    author_names = match[1].strip
    year = match[2].strip
    title_and_citation = match[3].strip

    reference = Bolton::Reference.create! :authors => author_names, :year => year,
      :title_and_citation => title_and_citation, :date => date
    Progress.dot
  end

  def extract_date string
    parts = string.split(/ ?\[([^\]]+)\]$/)
    return string, nil unless parts.length == 2
    return parts
  end

  def normalize string
    string = string.gsub(/\n/, ' ').strip
    string = string.gsub(/<.+?>/, '')
    string = CGI.unescapeHTML(string)
  end

end
