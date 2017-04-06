class AddReportDateToEncounter < ActiveRecord::Migration
  def change
    add_column :encounters, :report_date, :datetime
    add_index :encounters, :report_date
  end
end
