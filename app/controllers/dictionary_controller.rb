class DictionaryController < ApplicationController

  layout "ref"
  
  in_place_edit_for :concept, :name
  in_place_edit_for :concept, :description
 
  def show_concept
    @concept = Concept.find(params[:id])
  end

  def list_concepts
    @concepts = Concept.find(:all)
  end
end
