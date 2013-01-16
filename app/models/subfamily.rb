# coding: UTF-8
class Subfamily < Taxon
  include Updater
  has_many :tribes
  has_many :genera
  has_many :species
  has_many :subspecies
  has_many :collective_group_names, class_name: 'Genus', conditions: 'status = "collective group name"'

  def self.import data
    name = Name.import data
    transaction do
      if subfamily = find_by_name(name.name)
        subfamily.update_data data
      else
        attributes = {
          name:                name,
          fossil:              data[:fossil] || false,
          status:              data[:status] ||'valid',
          protonym:            Protonym.import(data[:protonym]),
          headline_notes_taxt: data[:headline_notes_taxt],
        }
        attributes.merge! get_type_attributes :type_genus, data
        subfamily = create! attributes
        data[:history].each do |item|
          subfamily.history_items.create! taxt: item
        end
      end
      subfamily
    end
  end

  def update_data data
    update_family_or_subfamily data
  end

  #########

  def children
    tribes
  end

  def statistics
    get_statistics [:tribes, :genera, :species, :subspecies]
  end

end
