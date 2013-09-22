class ConceptsController < ApplicationController
  layout 'ref'

  def add_answer
    @concept = Concept.find(params[:id])
    @concept_answer = Concept.where('name = ?', params[:concept_lookup]).first
    @answer = Answer.new(:concept_id => @concept.id, :answer_id => @concept_answer.id)
    @answer.save!
  end

  # GET /concepts
  # GET /concepts.json
  def index
    @concepts = Concept.includes(:answers).order(:name).all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @concepts }
    end
  end

  # GET /concepts/1
  # GET /concepts/1.json
  def show
    @concept = Concept.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @concept }
    end
  end

  # GET /concepts/new
  # GET /concepts/new.json
  def new
    @load_concepts_js_array = true # Triggers the layout to read the autocomplete array

    @concept = Concept.new
    @concept.name = "Edit_me"
    @concept.description = "Me too"
    @concept.save!

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @concept }
    end
  end

  # GET /concepts/1/edit
  def edit
    @concept = Concept.find(params[:id])
  end

  # POST /concepts
  # POST /concepts.json
  def create
    @concept = Concept.new(params[:concept])

    respond_to do |format|
      if @concept.save
        format.html { redirect_to @concept, notice: 'Concept was successfully created.' }
        format.json { render json: @concept, status: :created, location: @concept }
      else
        format.html { render action: "new" }
        format.json { render json: @concept.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /concepts/1
  # PUT /concepts/1.json
  def update
    @concept = Concept.find(params[:id])

    respond_to do |format|
      if @concept.update_attributes(params[:concept])
        format.html { redirect_to @concept, notice: 'Concept was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @concept.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /concepts/1
  # DELETE /concepts/1.json
  def destroy
    @concept = Concept.find(params[:id])
    @concept.destroy

    respond_to do |format|
      format.html { redirect_to concepts_url }
      format.json { head :no_content }
    end
  end

end