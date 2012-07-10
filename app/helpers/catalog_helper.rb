# coding: UTF-8
require 'snake'

module CatalogHelper
  def status_labels
    Formatters::CatalogFormatter.status_labels
  end

  def format_statistics statistics, include_invalid = true
    Formatters::CatalogFormatter.format_statistics statistics, :include_invalid => include_invalid
  end

  def make_catalog_search_results_columns items
    column_count = 5
    items.snake column_count
  end

  def search_selector current_search_type
    select_tag :search_type,
      options_for_select(['matching', 'beginning with', 'containing'], current_search_type || 'beginning with')
  end

  def taxonomic_history taxon
    Formatters::CatalogFormatter.format_taxonomic_history taxon
  end

  def index_column_link rank, taxon, selected_taxon, page_parameters = {}
    if taxon == 'none'
      classes = 'valid'
      classes << ' selected' if taxon == selected_taxon
      if rank == :subfamily
        parameters = "subfamily=none"
        parameters << "&hide_tribes=true" if page_parameters[:hide_tribes]
        parameters << "&hide_subgenera=true" if page_parameters[:hide_subgenera]
        link_to "(no subfamily)", "/catalog?#{parameters}", class: classes
      elsif rank == :tribe
        parameters = "subfamily=#{page_parameters[:subfamily].id}&tribe=none"
        link_to "(no tribe)", "/catalog?#{parameters}", class: classes
      end
    else
      label = Formatters::CatalogFormatter.taxon_label taxon
      css_classes = Formatters::CatalogFormatter.taxon_css_classes taxon, selected: taxon == selected_taxon
      # Using ndex_catalog_path slows things way down when used a lot (like making 1000 Camponotus species links)
      link_to label, "/catalog/#{taxon.id}?#{page_parameters.to_query}", class: css_classes
    end
  end

  def hide_link name, selected, page_parameters
    hide_param = "hide_#{name}".to_sym
    link_to 'hide', catalog_path(selected, page_parameters.merge(hide_param => true)), class: :hide
  end

  def show_child_link params, name, selected, page_parameters
    hide_child_param = "hide_#{name}".to_sym
    return unless params[hide_child_param]
    link_to "show #{name}", catalog_path(selected, page_parameters.merge(hide_child_param => false))
  end

  def snake_taxon_columns items
    column_count = items.count / 26.0
    css_class = 'taxon_item'
    if column_count < 1
      column_count = 1
    else
      column_count = column_count.ceil
    end
    if column_count >= 4
      column_count = 4
      css_class << ' teensy'
    end
    return items.snake(column_count), css_class
  end

  def creating_taxon_message rank, parent
    "Adding #{rank} to #{parent.name}"
  end

end
