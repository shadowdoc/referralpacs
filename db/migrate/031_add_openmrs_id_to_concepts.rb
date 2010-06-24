class AddOpenmrsIdToConcepts < ActiveRecord::Migration
  def self.up

    add_column :concepts, :openmrs_id, :integer
    
    global_map = [  
		         [1, 'PULMONARY INFILTRATE', 2397],
				 [66, 'RIGHT', 5141],
				 [67, 'LEFT', 5139],
				 [11, 'PERIHILAR', 2398],
				 [68, 'DIFFUSE', 576],
				 [2, 'PULMONARY CAVITATION', 6052], # Right, Left, Left
				 [69, 'NONE', 1107],
				 [71, 'BILATERAL', 2399],
				 [10, 'INTERSTITIAL LUNG PROCESS', 2400],
				 [70, 'LUNG SCARRING UPPER', 2401],
				 ['114', 'UPPER', 2402],  # no concept present in local database
				 [72, 'LUNG SCARRING LOWER', 2401],
				 ['115', 'LOWER', 2403],  # no concept present in local database
				 [73, 'PULMONARY NODULES', 2404],
	             [74, 'SOLITARY', 2405],
				 [75, 'TWO TO FIVE', 2406],
		         [76, 'MORE THAN FIVE', 2407],
			     [77, 'MILIARY CHANGES', 1137],
				 [39, 'CARDIOMEGALY', 5158],
				 [40, 'MILD', 1734],
				 [41, 'MODERATE', 1744],
				 [42, 'SEVERE', 1745],
				 [30, 'AORTA', 2409],
				 [34, 'NORMAL', 1115],
				 [31, 'UNFOLDED AORTA', 2410],
				 [81, 'AORTIC ANEURYSM', 2411],
                 [32, 'PULMONARY VASCULATURE', 2412],
                 [33, 'ENLARGED', 2185],
                 [83, 'DECREASED', 2413],
                 [78, 'PARATRACHEAL ADENOPATHY', 2414],
                 [99, 'ABSENT', 2415],
                 [96, 'PRESENT', 2416],
                 [79, 'HILAR ADENOPATHY', 2417],
                 [35, 'MEDIASTINAL MASS', 2418],
                 [59, 'PLEURAL EFFUSION', 1136],
                 [91, 'SMALL', 2428],
                 [92, 'LARGE', 2420],
                 [49, 'PLEURAL SCARRING', 2421], # direction dependent local answers but not local question?
                 [43, 'APICAL', 2422],  # R
                 [45, 'LATERAL', 542],  # R
                 [44, 'BASILAR', 2423], # R
                 [54, 'PNEUMOTHORAX', 2424],
                 [110, 'BONE FINDINGS ON CHEST XRAY?', 2425],
                 [94, 'OSTEOPOROSIS', 1516],
                 [57, 'ACUTE FRACTURE', 2426],
                 [58, 'HEALED FRACTURE', 2427],
                 [95, 'LUNG INFLATION', '????'],
                 [111, 'LUNG FINDINGS?', 2396],
                 [112, 'PLEURAL FINDINGS?', 2419],
                 [113, 'MEDIASTINAL FINDINGS?', 2408]]

    global_map.each do |concept_array|
       # Here we find by name because the names have to be correct for the form
       # To work correctly.  The ID numbers are not hard coded in the form.

       local_concept = Concept.find_by_name(concept_array[1])

       if local_concept.nil?
         puts "Concept #{concept_array[1]} not found!\n"
       else
         local_concept.openmrs_id = concept_array[2] unless local_concept.nil?
         local_concept.save
       end
    end
  end

  def self.down
    remove_column :concepts, :openmrs_id
  end
end
