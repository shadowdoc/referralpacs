class FhirController < ApplicationController
	layout false
	before_filter :check_security
	after_filter :format_json

	def check_security
		ip_addr = IPAddr.new(request.headers["REMOTE_ADDR"])
		Rails.logger.debug("fhir - call - x-api-key = #{request.headers["x-api-key"]}, ip = #{ip_addr}")

		if !(OPENMRS_ALLOWED_FHIR_IP_NETWORK === ip_addr)
			Rails.logger.error("fhir - error - security - invalid IP - #{ip_addr}")
			render :file => "public/401", :formats => [:html], :status => :unauthorized and return
		end

		@api_user = User.where("api_key = ?", request.headers["x-api-key"]).first
		if @api_user.nil?
			Rails.logger.error("fhir - error - security - invalid x-api-key - #{request.headers["x-api-key"]}")
			render :file => "public/401", :formats => [:html], :status => :unauthorized and return
		end
	end

	def diagnosticreport

		# FHIR diagnostic report interface with limited search support (https://www.hl7.org/fhir/search.html)
		# currently supported:
		# - query with a single Encounter ID
		# - patient searches
		# - date searches with the following prefixes - eq, ge, le, gt, lt  (https://www.hl7.org/fhir/search.html#prefix)

		Rails.logger.info("fhir - search request params: #{params} - user: #{@api_user.email}")

		# We do not allow open queries
		if params[:patient].nil? && params[:id].nil? && params[:date].nil?
			# code to return a failure
			render :error_open_query and return
		end

		# We have both patient and date searching
		if params[:patient] && params[:date]
			patient = Patient.includes(:encounters).find_openmrs(params[:patient])

			operator = get_date_operator(params[:date])

			@encounters = patient.encounters.where("date " + operator + " ?", Date.parse(params[:date]))

		end

		# Searching with patient identifier (OpenMRS ID)
		if params[:patient] && @encounters.nil?
			patient = Patient.includes(:encounters).find_openmrs(params[:patient])

			if patient.nil?
				# No patient returns an empty bundle
				@encounters = []
				render :error_no_patient_found and return
			else
				@encounters = patient.encounters
			end
		end

		if params[:date] && @encounters.nil?
			operator = get_date_operator(params[:date])
			@encounters = Encounter.where("date " + operator + " ?", Date.parse(params[:date]))
		end


		if params[:id]
			@encounters = [Encounter.find(params[:id])]
		end

		# Return a bundle (no or multiple results), or a resource (single result)

		if @encounters.nil? || @encounters.length == 0
			@encounters = []
			render :bundle and return
		end

		if @encounters.length > 1
			render :bundle and return
		else
			render partial: 'diagnosticreport', locals: {e: @encounters.first}
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


	def get_date_operator(date_parameter)
		case date_parameter[0..1]
			when "gt"
				operator = ">"
			when "lt"
				operator = "<"
			when "ge"
				operator = ">="
			when "le"
				operator = "<="
			else
				operator = "="
		end
	end
end
