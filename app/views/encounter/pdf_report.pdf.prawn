pdf.instance_eval do
   def write(some_text, style=:text)
      text some_text, :size=>font_size[style]
   end
   def separator
      write " ", :text
      stroke {y=@y-25; line [1,y], [bounds.width,y]}
      write " ", :text
   end
end


header_image = File.open("public/images/mtrhlogo.jpg")
pdf.image(header_image, :scale => 0.25, :align => :center)
header_image.close


pdf.text "PO Box 3, 3100 Eldoret Tel: +254-053-2033471/4", :size => 14, :align => :center
pdf.text "Chest X-ray Report", :size => 18, :align => :center
pdf.move_down(5)
pdf.separator
pdf.move_down(10)

pdf.text "Patient: #{@patient.full_name}", :size => 14, :justification => :left
pdf.text "ID: #{@patient.mrn_ampath}"
pdf.text "X-ray ID #{@patient.mtrh_rad_id}"
pdf.text "Birthdate: #{@patient.birthdate.strftime("%d-%m-%y")}"
pdf.move_down(10)
pdf.text "Film Date: #{@encounter.date.strftime("%d-%m-%y")}"
pdf.text "Report Date: #{@encounter.updated_at.strftime("%d-%m-%y")}"
pdf.move_down(5)
pdf.separator
pdf.move_down(10)

pdf.text "Clinical History:", :size => 14
pdf.text "#{@encounter.indication}", :size => 12
pdf.move_down(5)
pdf.separator
pdf.move_down(10)


pdf.text "Observations", :size => 15
@observations.each do |o|

  pdf.text "#{o.question_concept.name} - #{o.value_concept.name}"

end

pdf.move_down(5)
pdf.separator
pdf.move_down(10)

pdf.text("Impression:", :size => 15)
pdf.text(@encounter.impression)
pdf.move_down(20)
pdf.text "Reported and Signed by: #{@encounter.provider.full_name}"
pdf.render
