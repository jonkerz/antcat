# Note: This is the superclass of Species and Subspecies, not to
# be confused with "species group" as used in taxonomy.

class SpeciesGroupTaxon < Taxon
  include Formatters::ItalicsHelper

  belongs_to :subfamily
  belongs_to :genus
  belongs_to :subgenus

  validates :genus, presence: true

  before_create :set_subfamily

  def recombination?
    genus_epithet = name.genus_epithet
    protonym_genus_epithet = protonym.name.genus_epithet

    genus_epithet != protonym_genus_epithet
  end

  def inherit_attributes_for_new_combination old_comb, new_comb_parent
    raise "rank mismatch" unless can_inherit_for_new_combination_from? old_comb

    self.name = Taxa::NameForNewCombination[old_comb, new_comb_parent]

    copy_attributes_from old_comb, :protonym, :biogeographic_region
  end

  private

    def set_subfamily
      self.subfamily = genus.subfamily if genus && genus.subfamily
    end

    def can_inherit_for_new_combination_from? old_combination
      rank == old_combination.rank
    end
end
