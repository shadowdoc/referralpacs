class Concept < ActiveRecord::Base
  has_many :answers
  has_many :observations

  attr_accessible :name, :description, :openmrs_id
  
  validates_uniqueness_of :name

  def self.autocomplete
    # This returns a simple array of names for our 
    # Concept autocompleter
    concepts = Concept.select(:name).order(:name).all
    concept_array = []
    concepts.each {|c| concept_array << c.name}
    concept_array
  end
  
  def before_save
    self.name = self.name.upcase
  end
  
  def html_name
    self.name.downcase.gsub(" ", "_")
  end

end
