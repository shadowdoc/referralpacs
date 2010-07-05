class Observation < ActiveRecord::Base
  belongs_to :patient
  belongs_to :encounter
  belongs_to :question_concept,
             :class_name => "Concept",
             :foreign_key => "question_concept_id"
  belongs_to :value_concept,
             :class_name => "Concept",
             :foreign_key => "value_concept_id"


  def obx

    # There are several special cases where we will need to return more than one obx together.
    # This must return an array because sometimes more than one OBX segment will be returned.

    segments = []

    # The first case where we need more than one OBX is
    # PARENCHYMAL SCARRING/ATELECTASIS (OpenMRS Concept 2401)
    # This is represented in our system as LUNG SCARRING UPPER and LUNG SCARRING LOWER

    if self.question_concept.name =~ /LUNG SCARRING UPPER/
      # First add the question and the first portion of the answer
      obx = HL7::Message::Segment::OBX.new
      obx.value_type = 'CWE'
      obx.observation_id = '2041^PARENCHYMAL SCARRING/ATELECTASIS^99DCT'
      obx.observation_value = '2042^UPPER^99DCT'
      segments << obx

      obx = HL7::Message::Segment::OBX.new
      obx.value_type = 'CWE'
      obx.observation_id = '2041^PARENCHYMAL SCARRING/ATELECTASIS^99DCT'
      obx.observation_value = self.hl7_observation_value
      segments << obx

    elsif self.question_concept.name =~ /LUNG SCARRING LOWER/
      obx = HL7::Message::Segment::OBX.new
      obx.value_type = 'CWE'
      obx.observation_id = '2041^PARENCHYMAL SCARRING/ATELECTASIS^99DCT'
      obx.observation_value = '2043^LOWER^99DCT'
      segments << obx

      obx = HL7::Message::Segment::OBX.new
      obx.value_type = 'CWE'
      obx.observation_id = '2041^PARENCHYMAL SCARRING/ATELECTASIS^99DCT'
      obx.observation_value = self.hl7_observation_value
      segments << obx
  
    elsif self.question_concept.name =~ /PLEURAL EFFUSION RIGHT/
      obx = HL7::Message::Segment::OBX.new
      obx.value_type = 'CWE'
      obx.observation_id = '1136^PLEURAL EFFUSION^99DCT'
      obx.observation_value = '5141^RIGHT^99DCT'
      segments << obx

      obx = HL7::Message::Segment::OBX.new
      obx.value_type = 'CWE'
      obx.observation_id = '1136^PLEURAL EFFUSION^99DCT'
      obx.observation_value = self.hl7_observation_value
      segments << obx
      
    elsif self.question_concept.name =~ /PLEURAL EFFUSION LEFT/
      obx = HL7::Message::Segment::OBX.new
      obx.value_type = 'CWE'
      obx.observation_id = '1136^PLEURAL EFFUSION^99DCT'
      obx.observation_value = '5139^LEFT^99DCT'
      segments << obx

      obx = HL7::Message::Segment::OBX.new
      obx.value_type = 'CWE'
      obx.observation_id = '1136^PLEURAL EFFUSION^99DCT'
      obx.observation_value = self.hl7_observation_value
      segments << obx

    elsif self.question_concept.name =~ /PLEURAL SCARRING/

      # This first section puts on the laterality modifier

      obx = HL7::Message::Segment::OBX.new
      obx.value_type = 'CWE'
      obx.observation_id = '2421^PLEURAL SCARRING^99DCT'

      if self.value_concept.name =~ /LEFT/
        obx.observation_value = '5139^LEFT^99DCT'
      else
        obx.observation_value = '5141^RIGHT^99DCT'
        segments << obx
      end
      segments << obx

      # This next section adds the location (apical, lateral, or basilar)

      obx = HL7::Message::Segment::OBX.new
      obx.value_type = 'CWE'
      obx.observation_id = '2421^PLEURAL SCARRING^99DCT'

      if self.value_concept.name =~ /APICAL/
        obx.observation_value = '2422^APICAL^99DCT'
      elsif self.value_concept.name =~ /LATERAL/
        obx.observation_value = '542^LATERAL^99DCT'
      else
        obx.observation_value = '2423^BASILAR^99DCT'
      end
      segments << obx

    elsif self.question_concept.name =~ /PNEUMOTHORAX RIGHT/
      obx = HL7::Message::Segment::OBX.new
      obx.value_type = 'CWE'
      obx.observation_id = '2424^PNEUMOTHORAX^99DCT'
      obx.observation_value = '5141^RIGHT^99DCT'
      segments << obx

      obx = HL7::Message::Segment::OBX.new
      obx.value_type = 'CWE'
      obx.observation_id = '2424^PNEUMOTHORAX^99DCT'
      obx.observation_value = self.hl7_observation_value
      segments << obx

    elsif self.question_concept.name =~ /PNEUMOTHORAX LEFT/
      obx = HL7::Message::Segment::OBX.new
      obx.value_type = 'CWE'
      obx.observation_id = '2424^PNEUMOTHORAX^99DCT'
      obx.observation_value = '5139^LEFT^99DCT'
      segments << obx

      obx = HL7::Message::Segment::OBX.new
      obx.value_type = 'CWE'
      obx.observation_id = '2424^PNEUMOTHORAX^99DCT'
      obx.observation_value = self.hl7_observation_value
      segments << obx
    else

      # This is the clause for observations that are not nested.

      obx = HL7::Message::Segment::OBX.new
      obx.value_type = 'CWE'
      obx.observation_id = self.hl7_question
	  obx.observation_value = self.hl7_observation_value
      segments << obx

    end


	return segments
  end

  def hl7_question
    self.question_concept.openmrs_id.to_s + '^' + self.question_concept.name + '^99DCT'
  end

  def hl7_observation_value
    self.value_concept.openmrs_id.to_s + '^' + self.value_concept.name + '^99DCT'
  end
  
end