# This class is for parsing taxts in the "database format" (strings
# such as "hey {ref 123}") to something that can be read.

class TaxtPresenter
  include ApplicationHelper # For `#add_period_if_necessary`.

  def initialize taxt_from_db
    @taxt = taxt_from_db.try :dup
  end
  class << self; alias_method :[], :new end

  # Parses "example {tax 429361}"
  # into   "example <a href=\"/catalog/429361\">Melophorini</a>"
  def to_html
    parse :to_html
  end

  # Parses "example {tax 429361}"
  # into   "example Melophorini"
  def to_text
    parsed = parse :to_text
    # TODO see if we can push `add_period_if_necessary` to the consumer.
    add_period_if_necessary parsed
  end

  # Not used, because we're still relying on `$use_ant_web_formatter`.
  def to_antweb
    parse :to_antweb
  end

  private
    def parse format
      return '' unless @taxt.present?

      @format = format
      maybe_enable_antweb_quirk

      parse_refs!
      parse_nams!
      parse_taxs!

      @taxt.html_safe
    end

    # References, "{ref 123}".
    def parse_refs!
      @taxt.gsub!(/{ref (\d+)}/) do
        reference = Reference.find_by id: $1

        if reference
          case @format
          when :to_html   then reference.decorate.inline_citation
          when :to_text   then reference.keey
          when :to_antweb then reference.decorate.antweb_version_of_inline_citation
          end
        else
          warn_about_non_existing_id "REFERENCE", $1
        end
      end
    end

    # Names, "{nam 123}".
    def parse_nams!
      @taxt.gsub!(/{nam (\d+)}/) do
        name = Name.find_by id: $1

        if name
          name.to_html
        else
          warn_about_non_existing_id "NAME", $1
        end
      end
    end

    # Taxa, "{tax 123}".
    def parse_taxs!
      @taxt.gsub!(/{tax (\d+)}/) do
        taxon = Taxon.find_by id: $1

        if taxon
          case @format
          when :to_html   then taxon.decorate.link_to_taxon
          when :to_text   then taxon.name.to_html
          when :to_antweb then Exporters::Antweb::Exporter.antcat_taxon_link_with_name taxon
          end
        else
          warn_about_non_existing_id "TAXON", $1
        end
      end
    end

    def maybe_enable_antweb_quirk
      @format = :to_antweb if $use_ant_web_formatter
    end

    def warn_about_non_existing_id klass, id
      <<-HTML.squish
        <span class="bold-warning">
          CANNOT FIND #{klass} WITH ID #{id}
        </span>
      HTML
    end
end