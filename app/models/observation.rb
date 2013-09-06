class Observation < ActiveRecord::Base
  belongs_to :patient
  belongs_to :encounter
  belongs_to :question_concept,
             :class_name => "Concept",
             :foreign_key => "question_concept_id"
  belongs_to :value_concept,
             :class_name => "Concept",
             :foreign_key => "value_concept_id"


  def obx(segment_id)

    @segment_id = segment_id

    def new_obx
      # Shortcut to create a new OBX segment
      # This sets up all of the static default segments

      o = HL7::Message::Segment::OBX.new
      o.value_type = 'CWE'
      o.observation_id = '2395^CHEST X-RAY FINDINGS BY RADIOLOGY^99DCT'
      o.e4 = @segment_id
      o.e11 = 'F' # Set result status to final
      o.time = self.encounter.date.strftime("%Y%m%d%H%M%S")
      o
    end

    obs_array = []

    # There are several cases where our system has a single concept that maps
    # to several concepts in OpenMRS.  We need to pull those out and treat them specifically

    # The first case where we need more than one OpenMRS concept is
    # PARENCHYMAL SCARRING/ATELECTASIS (OpenMRS Concept 2401)
    # This is represented in our system as LUNG SCARRING UPPER and LUNG SCARRING LOWER

    if self.question_concept.name =~ /LUNG SCARRING UPPER/
      # First add the question and the first portion of the answer

      obs_array = ['2401^PARENCHYMAL SCARRING/ATELECTASIS^99DCT', '2403^LOWER^99DCT', self.hl7_observation_value]

    elsif self.question_concept.name =~ /LUNG SCARRING LOWER/

      obs_array = ['2401^PARENCHYMAL SCARRING/ATELECTASIS^99DCT', '2402^UPPER^99DCT', self.hl7_observation_value]
  
    elsif self.question_concept.name =~ /PLEURAL EFFUSION RIGHT/

      obs_array = ['1136^PLEURAL EFFUSION^99DCT', '5141^RIGHT^99DCT', self.hl7_observation_value]

    elsif self.question_concept.name =~ /PLEURAL EFFUSION LEFT/

      obs_array = ['1136^PLEURAL EFFUSION^99DCT', '5139^LEFT^99DCT', self.hl7_observation_value]

    elsif self.question_concept.name =~ /PLEURAL SCARRING/

      obs_array = ['2421^PLEURAL SCARRING^99DCT']

      if self.value_concept.name =~ /LEFT/
        obs_array << '5139^LEFT^99DCT'
      else
        obs_array << '5141^RIGHT^99DCT'
      end

      # This next section adds the location (apical, lateral, or basilar)

      if self.value_concept.name =~ /APICAL/
        obs_array << '2422^APICAL^99DCT'
      elsif self.value_concept.name =~ /LATERAL/
        obs_array << '542^LATERAL^99DCT'
      else
        obs_array << '2423^BASILAR^99DCT'
      end

    elsif self.question_concept.name =~ /PNEUMOTHORAX RIGHT/

      obs_array <<  '2424^PNEUMOTHORAX^99DCT'
      obs_array <<  '5141^RIGHT^99DCT'
      obs_array << self.hl7_observation_value

    elsif self.question_concept.name =~ /PNEUMOTHORAX LEFT/

      obs_array <<  '2424^PNEUMOTHORAX^99DCT'
      obs_array << '5139^LEFT^99DCT'
      obs_array << self.hl7_observation_value

    else

      # This is the clause for observations that are not nested.
      obs_array << self.hl7_question
	    obs_array << self.hl7_observation_value

    end

	  obx = new_obx
    obx.observation_value = obs_array.join('~')

    [obx]
  end

  def hl7_question
    self.question_concept.openmrs_id.to_s + '^' + self.question_concept.name + '^99DCT'
  end

  def hl7_observation_value
    self.value_concept.openmrs_id.to_s + '^' + self.value_concept.name + '^99DCT'
  end
  
end