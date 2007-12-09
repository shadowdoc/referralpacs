require "#{File.dirname(__FILE__)}/../test_helper"

class LibUsermonitorTest < ActionController::IntegrationTest
  fixtures :users, :patients
  
  def test_created_by
    post('login/login', 
         :user => {:email => users(:admin).email, 
                   :password => "password"})

    get('admin/new_patient')
    assert :success
    assert_template 'admin/new_patient'
    assert Thread.current['user'], users(:admin)
    
    assert Patient.count, 2
    
    post('admin/new_patient',
        {:patient => {:given_name => "Evelyn",
                      :family_name => "Wasike",
                      :mtrh_rad_id => 12346,
                      :mrn_ampath => 5321,
                      :tribe_id => 2}})
    
    assert :success
    assert_redirected_to :action => "find_encounters"    
    
    assert Patient.count, 3
    
    wasike = Patient.find(:first, :conditions => ["mtrh_rad_id = ?", 12346])
    
    assert wasike.created_by, 1
    
  end
  
end
