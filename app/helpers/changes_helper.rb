# coding: UTF-8
module ChangesHelper
  include Formatters::Formatter
  include Formatters::ChangesFormatter

  def link_to_taxon taxon
    label = taxon.name.to_html_with_fossil(taxon.fossil?)
    content_tag :a, label, href: %{/catalog/#{taxon.id}}
  end

  def format_adder_name user_id
    "#{format_doer_name user_id} added"
  end

  def format_taxon_name name
    name.name_html.html_safe
  end

  def format_rank rank
    rank.display_string
  end

  def format_status status
    Status[status].to_s
  end

  def format_reference reference
    Formatters::ReferenceFormatter.format reference
  end

  def format_attributes taxon
    string = []
    string << 'Fossil' if taxon.fossil?
    string << 'Hong' if taxon.hong?
    string << '<i>nomen nudum</i>' if taxon.nomen_nudum?
    string << 'unresolved homonym' if taxon.unresolved_homonym?
    string << 'ichnotaxon' if taxon.ichnotaxon?
    string.join(', ').html_safe
  end

  def format_protonym_attributes taxon
    protonym = taxon.protonym
    string = []
    string << 'Fossil' if protonym.fossil?
    string << '<i>sic</i>' if protonym.sic?
    string.join(', ').html_safe
  end

  def format_type_attributes taxon
    string = []
    string << 'Fossil' if taxon.type_fossil?
    string.join(', ').html_safe
  end

  def format_taxt taxt
    Taxt.to_string taxt, current_user
  end

  def approve_button taxon
    if taxon.can_be_approved_by? current_user
      content_tag :button, 'Approve', type: 'button', id: 'approve_button', 'data-approve-location' => "/changes/#{taxon.last_change.id}/approve}"
    end
  end

end
