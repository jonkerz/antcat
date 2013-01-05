module Taxt
  class ReferenceNotFound < StandardError; end
  class TaxonNotFound < StandardError; end
  class NameNotFound < StandardError; end
  class IdNotFound < StandardError; end

  ################################
  def self.to_string taxt, user = nil, options = {}
    decode taxt, user, options
  end

  def self.to_sentence taxt, user
    string = decode taxt, user
    Formatters::Formatter.add_period_if_necessary string
  end

  ################################
  def self.to_editable taxt
    return '' unless taxt
    taxt = taxt.dup

    if taxt =~ /{ref/
      taxt.gsub! /{ref (\d+)}/ do |ref|
        editable_id = id_for_editable $1, 1
        to_editable_reference Reference.find($1) rescue "{#{editable_id}}"
      end
    end

    if taxt =~ /{tax/
      taxt.gsub! /{tax (\d+)}/ do |tax|
        editable_id = id_for_editable $1, 2
        to_editable_taxon Taxon.find($1) rescue "{#{editable_id}}"
      end
    end

    if taxt =~ /{nam/
      taxt.gsub! /{nam (\d+)}/ do |nam|
        editable_id = id_for_editable $1, 3
        to_editable_name Name.find($1) rescue "{#{editable_id}}"
      end
    end

    taxt
  end

  def self.to_editable_reference reference
    editable_id = id_for_editable reference.id, 1
    "{#{reference.key.to_s} #{editable_id}}"
  end

  def self.to_editable_taxon taxon
    editable_id = id_for_editable taxon.id, 2
    "{#{taxon.name} #{editable_id}}"
  end

  def self.to_editable_name name
    editable_id = id_for_editable name.id, 3
    "{#{name.name} #{editable_id}}"
  end

  # this value is duplicated in taxt_editor.coffee
  EDITABLE_ID_DIGITS = %{abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ}

  def self.from_editable editable_taxt
    editable_taxt.gsub /{((.*?)? )?([#{Regexp.escape EDITABLE_ID_DIGITS}]+)}/ do |string|
      id, type_number = id_from_editable $3
      case type_number
      when 1
        raise ReferenceNotFound.new(string) unless Reference.find_by_id id
        "{ref #{id}}"
      when 2
        raise TaxonNotFound.new(string) unless Taxon.find id
        "{tax #{id}}"
      when 3
        raise NameNotFound.new(string) unless Name.find id
        "{nam #{id}}"
      end
    end
  end

  def self.id_for_editable id, type_number
    AnyBase.base_10_to_base_x(id.to_i * 10 + type_number, EDITABLE_ID_DIGITS).reverse
  end

  # this code is duplicated in taxt_editor.coffee
  def self.id_from_editable editable_id
    number = AnyBase.base_x_to_base_10(editable_id.reverse, EDITABLE_ID_DIGITS) 
    id = number / 10
    type_number = number % 10
    return id, type_number
  end

  ################################
  def self.decode taxt, user = nil, options = {}
    return '' unless taxt
    taxt.gsub(/{ref (\d+)}/) do |whole_match|
      decode_reference whole_match, $1, user, options
    end.gsub(/{nam (\d+)}/) do |whole_match|
      decode_name whole_match, $1
    end.gsub(/{tax (\d+)}/) do |whole_match|
      decode_taxon whole_match, $1, options
    end.html_safe
  end

  def self.decode_reference whole_match, reference_id_match, user, options
    Formatters::ReferenceFormatter.format_inline_citation(Reference.find(reference_id_match), user, options) rescue whole_match
  end

  def self.decode_name whole_match, name_id_match
    Name.find(name_id_match).to_html rescue whole_match
  end

  def self.decode_taxon whole_match, taxon_id_match, options
    taxon = Taxon.find taxon_id_match
    (options[:formatter] || Formatters::TaxonFormatter).link_to_taxon taxon
  rescue
    whole_match
  end

  ################################
  def self.encode_unparseable string
    "{? #{string}}"
  end

  def self.encode_reference reference
    "{ref #{reference.id}}"
  end

  def self.encode_taxon_name data
    "{nam #{Name.import(data).id}}"
  end

  ################################
  def self.replace replace_what, replace_with
    TaxonHistoryItem
    [[Taxon,            [:type_taxt, :headline_notes_taxt, :genus_species_header_notes_taxt]],
     [ReferenceSection, [:title, :subtitle, :references]],
     [TaxonHistoryItem, [:taxt]],
    ].each do |klass, fields|
      for record in klass.send :all
        for field in fields
          next unless record[field]
          record[field] = record[field].gsub replace_what, replace_with
        end
        record.save!
      end
    end
  end

end
