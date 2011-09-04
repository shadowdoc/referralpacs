class QualityCheck < ActiveRecord::Base
  belongs_to :encounter
  belongs_to :provider
  belongs_to :reviewer, :class_name => "User", :foreign_key => "reviewer_id"
end
