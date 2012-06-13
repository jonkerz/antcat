class SubspeciesName < Name

  belongs_to :species_name
  validates :species_name, presence: true

  belongs_to :next_subspecies_name, class_name: 'SubspeciesName'
  belongs_to :prior_subspecies_name, class_name: 'SubspeciesName'

  def self.import data
    return unless data[:subspecies]

    if data[:species]
      species_name = data[:species].name
    else
      species_name = SpeciesName.import data
    end

    name_string = species_name.name.dup
    for subspecies in data[:subspecies]
      name_string << ' ' << subspecies[:type] if subspecies[:type]
      name_string << ' ' << subspecies[:species_group_epithet]
    end

    name = Name.find_by_name name_string
    return name if name

    subspecies = data[:subspecies].first
    name = create! name: name_string, epithet: subspecies[:species_group_epithet], subspecies_qualifier: subspecies[:type], species_name: species_name
    subspecies_name = name
    prior_name = name

    subspecies = data[:subspecies].second
    if subspecies
      name = create! name: name_string, epithet: subspecies[:species_group_epithet], subspecies_qualifier: subspecies[:type], species_name: species_name,
        prior_subspecies_name: prior_name
      prior_name.update_attribute :next_subspecies_name, name
    end

    subspecies_name
  end

  def rank
    'subspecies'
  end

end
