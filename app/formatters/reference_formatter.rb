# TODO: Do not cache in database.
# TODO: Cleanup. Can wait until `MissingReference` has been removed.

class ReferenceFormatter
  include ActionView::Helpers::TagHelper # For `#content_tag`.
  include ActionView::Context # For `#content_tag`.
  include ActionView::Helpers::SanitizeHelper # For `#sanitize`.

  include Rails.application.routes.url_helpers
  include ActionView::Helpers

  include ApplicationHelper # For `#unitalicize`, `#add_period_if_necessary`.

  def initialize reference
    @reference = reference
  end

  # Formats the reference as plaintext (with the exception of <i> tags).
  def plain_text
    return generate_plain_text if ENV['NO_REF_CACHE']

    cached = reference.plain_text_cache
    return cached.html_safe if cached

    reference.set_cache generate_plain_text, :plain_text_cache
  end

  # Formats the reference with HTML, CSS, etc. Click to show expanded.
  def expandable_reference
    return generate_expandable_reference if ENV['NO_REF_CACHE']

    cached = reference.expandable_reference_cache
    return cached.html_safe if cached

    reference.set_cache generate_expandable_reference, :expandable_reference_cache
  end

  # Formats the reference with HTML, CSS, etc.
  def expanded_reference
    return generate_expanded_reference if ENV['NO_REF_CACHE']

    cached = reference.expanded_reference_cache
    return cached.html_safe if cached

    reference.set_cache generate_expanded_reference, :expanded_reference_cache
  end

  private

    attr_reader :reference

    # TODO: Very "hmm" case statement.
    def format_citation
      case reference
      when ArticleReference
        sanitize "#{reference.journal.name} #{reference.series_volume_issue}:#{reference.pagination}"
      when BookReference
        sanitize "#{reference.publisher.display_name}, #{reference.pagination}"
      when NestedReference
        sanitize "#{reference.pages_in} #{sanitize ReferenceFormatter.new(reference.nesting_reference).expanded_reference}"
      when MissingReference, UnknownReference
        sanitize reference.citation
      else
        raise
      end
    end

    def generate_plain_text
      string = sanitize(reference.author_names_string_with_suffix)
      string << ' ' unless string.empty?
      string << sanitize(reference.citation_year) << '. '
      string << unitalicize(reference.decorate.format_plain_text_title) << ' '
      string << add_period_if_necessary(format_plain_text_citation)
      string
    end

    def generate_expandable_reference
      inner_content = []
      inner_content << generate_expanded_reference
      inner_content << '[online early]' if reference.online_early?
      inner_content << reference.decorate.format_document_links
      content = inner_content.reject(&:blank?).join(' ')

      # TODO: `tabindex: 2` is required or tooltips won't stay open even with `data-click-open="true"`.
      content_tag :span, sanitize(reference.keey),
        data: { tooltip: true, allow_html: "true", tooltip_class: "foundation-tooltip" },
        tabindex: "2", title: content.html_safe
    end

    def generate_expanded_reference
      string = sanitize author_names_with_links
      string << ' ' unless string.empty?
      string << sanitize(reference.citation_year) << '. '
      string << format_title_with_link << ' '
      string << format_italics(add_period_if_necessary(format_citation))
      string << ' [online early]' if reference.online_early?

      string
    end

    # `format_italics` + `unitalicize` is to get rid of "*" italics.
    def format_plain_text_citation
      case reference
      when NestedReference
        sanitize "#{reference.pages_in} #{ReferenceFormatter.new(reference.nesting_reference).plain_text}"
      else
        unitalicize format_italics(sanitize(format_citation))
      end
    end

    def author_names_with_links
      string =  reference.author_names.map do |author_name|
                  link_to(sanitize(author_name.name), author_path(author_name.author))
                end.join('; ')

      string << sanitize(" #{reference.author_names_suffix}") if reference.author_names_suffix.present?
      string
    end

    def format_title_with_link
      link_to reference.decorate.format_plain_text_title, reference_path(reference)
    end

    def format_italics string
      References::FormatItalics[string]
    end
end
