crumb :edit_catalog do
  link "Edit Catalog"
end

crumb :new_taxon do
  link "Add Taxon"
  parent :edit_catalog
end

crumb :taxon_being_edited do |taxon|
  if taxon
    link "#{taxon.name_html_cache} (##{taxon.id})".html_safe, catalog_path(taxon)
  else
    link "[deleted]"
  end
  parent :edit_catalog
end

crumb :edit_taxon do |taxon|
  link "Edit", edit_taxa_path(taxon)
  parent :taxon_being_edited, taxon
end

  crumb :edit_taxon_show_children do |taxon|
    link "Show Children"
    parent :edit_taxon, taxon
  end

  crumb :confirm_before_delete_taxon do |taxon|
    link "Confirm before delete taxon (superadmin)"
    parent :edit_taxon, taxon
  end

crumb :convert_to_species do |taxon|
  link "Convert to Species"
  parent :edit_taxon, taxon
end

crumb :search_taxon_history_items do
  link "Search History Items"
  parent :catalog
end

crumb :search_reference_sections do
  link "Search Reference Sections"
  parent :catalog
end

crumb :taxon_history_items do |taxon|
  link "History Items"
  parent :taxon_being_edited, taxon
end

  crumb :taxon_history_item do |item|
    link "##{item.id}"
    parent :taxon_history_items, item.taxon
  end

crumb :reference_sections do |taxon|
  link "Reference Sections"
  parent :taxon_being_edited, taxon
end

  crumb :reference_section do |reference_section|
    link "##{reference_section.id}"
    parent :reference_sections, reference_section.taxon
  end

crumb :synonym_relationship do |synonym|
  link "Synonym Relationship ##{synonym.id}"
  parent :edit_catalog
end
