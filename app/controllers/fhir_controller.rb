class FhirController < ApplicationController
	layout false
	before_filter :check_api_key
	after_filter :format_json

	def check_api_key
		Rails.logger.debug("fhir - called with x-api-key = #{request.headers["x-api-key"]}, searching for user")

		@api_user = User.where("api_key = ?", request.headers["x-api-key"]).first
		if @api_user.nil?
			render :file => "public/401", :formats => [:html], :status => :unauthorized and return
		end
	end

	def diagnosticreport
		Rails.logger.info("fhir - search request for openmrs_mrn: #{params[:patient]} - user: #{@api_user.email}")

		if params[:patient].nil? && params[:id].nil?
			# code to return a failure
			render :error_open_query and return
		end

		if params[:patient]
			patient = Patient.includes(:encounters).find_openmrs(params[:patient])
	
			if patient.nil?
				# No patient returns an empty bundle
				@encounters = []
				render :error_no_patient_found and return
			else
				@encounters = patient.encounters
			end
		else 
			@encounters = [Encounter.find(params[:id])]
		end

		# Return a bundle (no or multiple results), or a resource (single result)
		if @encounters.nil?
			@encounters = []
			render :bundle and return
		end

		if @encounters.length > 1
			render :bundle and return
		else
			render partial: 'diagnosticreport'
		end

	end

	private
	def format_json
		if OPENMRS_JSON_FORMAT == "pretty"
			json = JSON.parse(response.body)
			response.body = JSON.pretty_generate(json)
		end

		if OPENMRS_JSON_FORMAT == "min"
			json = JSON.parse(response.body)
			response.body = json.to_json
		end
	end

end
