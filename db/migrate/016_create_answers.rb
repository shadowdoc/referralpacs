class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers do |t|
      t.column :concept_id, :integer
      t.column :answer_id, :integer
    end
  end

  def self.down
    drop_table :answers
  end
end
