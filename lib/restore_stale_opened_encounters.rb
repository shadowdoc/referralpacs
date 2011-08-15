# This is meant to run within the rails framework.

# We're looking for any encounter that has been opened for more than an hour, this will put
# The encounter back into "new" status so that it can be read again.
# This task should run hourly - with crontab.

begin_time = Time.now - 7.days
end_time = Time.now - 1.hour

stale = Encounter.all(:conditions => {:updated_at => begin_time..end_time, :status => "opened"})

stale.each do |e|

  e.status = "new"
  e.save!

end
