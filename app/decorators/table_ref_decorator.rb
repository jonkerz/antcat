# frozen_string_literal: true

class TableRefDecorator
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  attr_private_initialize :table_ref

  def item_link
    case table
    when "citations"           then id
    when "protonyms"           then link_to(id, protonym_path(id))
    when "reference_sections"  then link_to(id, reference_section_path(id))
    when "references"          then link_to(id, reference_path(id))
    when "taxa"                then link_to(id, catalog_path(id))
    when "taxon_history_items" then link_to(id, taxon_history_item_path(id))
    else                       raise "unknown table #{table}"
    end
  end

  def owner_link
    case owner
    when Taxon     then CatalogFormatter.link_to_taxon(owner)
    when Reference then owner.decorate.expandable_reference
    when Protonym  then ("Protonym: ".html_safe << owner.decorate.link_to_protonym)
    else           raise "unknown owner #{owner.class.name}"
    end
  end

  private

    delegate :table, :id, :owner, to: :table_ref, private: true
end
