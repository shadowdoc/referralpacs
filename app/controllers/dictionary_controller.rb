class DictionaryController < ApplicationController

  layout "ref"
  
  in_place_edit_for :concept, :name
  in_place_edit_for :concept, :description
  
  def concepts_for_lookup
    # TODO: Currently, all of the concepts are listed by the autocomplete
    # Would like only the answers for the selected concept to show up under 
    # answers
    
    @concepts = Concept.order(:name).all
    headers['content-type'] = 'text/javascript'
    render :layout => false
  end
 
  def show_concept
    @load_concepts_js_array = true # Triggers the layout to read the autocomplete array
    if params[:id].nil?
      @concept = Concept.new
      @concept.name = "Edit_me"
      @concept.description = "Me too"
      @concept.save!
    else
      @concept = Concept.find(params[:id])
    end
  end

  def list_concepts
    @concepts = Concept.order(:name).all
  end
  
  def add_answer
    @concept = Concept.find(params[:id])
    @concept_answer = Concept.where('name = ?', params[:concept_lookup]).first
    @answer = Answer.new(:concept_id => @concept.id, :answer_id => @concept_answer.id)
    @answer.save!
    render :partial => "answer", :object => @answer, :layout => false
  end
end