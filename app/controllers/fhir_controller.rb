class FhirController < ApplicationController
	layout false
	before_filter :check_security, :set_params_fhir
	after_filter :format_json

	def diagnosticreport

		@resource_type = "diagnosticreport"
		get_fhir

	end

	def imagingstudy

		@resource_type = "imagingstudy"
		get_fhir
	end

	def get_fhir
		# FHIR diagnostic report interface with limited search support (https://www.hl7.org/fhir/search.html)
		# currently supported:
		# - query with a single Encounter ID
		# - patient searches
		# - date searches with the following prefixes - eq, ge, le, gt, lt  (https://www.hl7.org/fhir/search.html#prefix)

		Rails.logger.info("fhir - search request user: #{@api_user.email}")
		Rails.logger.debug("fhir - search - @params_fhir: #{@params_fhir} - params: #{params}")

		# We do not allow open queries
		# There are always two parameters (controller, action) in the parameter hash
		# if a patient, ID or date is specified, the length of the hash will be larger
		if params.keys.length <= 2
			# code to return a failure
			render :error_open_query and return
		end

		# We have both patient and date searching
		if @params_fhir["patient"] && @params_fhir["date"]
			Rails.logger.info("fhir - search by OpenMRS ID and Date")
			patient = Patient.includes(:encounters).find_openmrs(@params_fhir["patient"])

			if !patient.nil?
				operator = get_date_operator(@params_fhir["date"])

				@encounters = set_date_where(patient.encounters)
			end
		end

		# Searching with patient identifier (OpenMRS ID)
		if @params_fhir["patient"] && @encounters.nil?
			Rails.logger.info("fhir - search by OpenMRS ID")
			patient = Patient.includes(encounters: {dcm4chee_study: {dcm4chee_series: :dcm4chee_instances}}).find_openmrs(@params_fhir["patient"])

			if patient.nil?
				# No patient returns an empty bundle
				@encounters = []
				render :error_no_patient_found and return
			else
				@encounters = patient.encounters
			end
		end

		if @params_fhir["date"] && @encounters.nil?
			Rails.logger.info("fhir - search by Date alone")
			@encounters = set_date_where(Encounter)
		end


		if params[:id] && @encounters.nil?
			Rails.logger.info("fhir - search by Encounter ID")
			@encounters = [Encounter.includes(dcm4chee_study: {dcm4chee_series: :dcm4chee_instances}).find(params[:id])]
			render partial: @resource_type, locals: {e: @encounters.first} and return
		end

		# For ImagingStudy resources, we need to remove the non-DICOM encounters
		if @resource_type == "imagingstudy"
			enc_temp = []
			@encounters.each {|e| enc_temp << e if e.study_uid}
			@encounters = enc_temp
		end

		# Return a bundle (no or multiple results), or a resource (single result)

		if @encounters.nil? || @encounters.length == 0
			@encounters = []
		end

		render :bundle and return

	end

	private

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

	def format_json

		json = JSON.parse(response.body)

		if OPENMRS_JSON_FORMAT == "pretty"
			response.body = JSON.pretty_generate(json)
		end

		if OPENMRS_JSON_FORMAT == "min"
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

	def set_date_where(relation)

		if @params_fhir["date"].kind_of?(Array)
			start_date = Date.parse(@params_fhir["date"][0])
			end_date = Date.parse(@params_fhir["date"][1])
			return relation.where("date between ? and ?", start_date, end_date)
		else
			operator = get_date_operator(@params_fhir["date"])
			return relation.where("date " + operator + " ?", Date.parse(@params_fhir["date"]))
		end

	end

	def set_params_fhir
		# This code is needed to handle date range query strings
		# for example: /fhir/diagnosticreport?date=gt2015-01-01&date=lt2015-12-31
		# when parsed by Rails, params only includes the first date

		@params_fhir = Rack::Utils.parse_query(request.fullpath.split("?")[1])
		Rails.logger.debug("fhir - set_params_fhir - request.fullpath: #{request.fullpath} - params_fhir: #{@params_fhir}")
	end

end
