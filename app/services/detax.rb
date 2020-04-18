# frozen_string_literal: true

class Detax
  include Service

  attr_private_initialize :taxt

  # Parses "example {tax 429361}"
  # into   "example <a href=\"/catalog/429361\">Melophorini</a>"
  def call
    return unless taxt
    Markdowns::ParseCatalogTags[taxt.dup].html_safe
  end
end
