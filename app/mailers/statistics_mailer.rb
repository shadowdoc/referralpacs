class StatisticsMailer < ActionMailer::Base
  default :from => "radtrack@iupui.edu"
  layout "mailer"

  def truck(start_date, end_date)

    @start_date = start_date
    @end_date = end_date

    @stat_hash = Encounter.group(:status).count

    @enc_relation = Encounter.includes(:location).where("date between ? and ?", start_date, end_date).where(status: "final")

    @total = @enc_relation.count
    @normal = @enc_relation.where(impression: "Normal").count


    @active_providers = Encounter.includes(:provider)
                                 .where("updated_at between ? and ?", start_date, end_date)
                                 .where(status: "final")
                                 .group(:provider).count
    @active_providers = @active_providers.sort {|a1, a2| a2[1] <=> a1[1]}

    @location_hash = @enc_relation.includes(:location).group('location').count

    @location_hash = @location_hash.sort {|a1, a2| a2[1] <=> a1[1]}

    @obs_hash = Hash.new 0

    obs = Observation.includes(:question_concept, :value_concept)
                     .joins(:encounter)
                     .where('encounters.date between ? and ?', start_date, end_date)

    obs.each {|o| @obs_hash[o.question_concept.name + "-" + o.value_concept.name] += 1}

    @obs_hash = @obs_hash.sort {|a1, a2| a2[1] <=> a1[1]}

    mail(:subject => "X-ray Truck Report",
       :date => Time.now,
       :to => STATISTICS_EMAIL_LIST,
       :content_type => "text/html")

  end


end