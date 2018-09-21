Referral PACS
=============
Ruby on Rails application that when coupled with a dcm4chee archive, provides image storage and coded reporting for chest radiographs.

Features:
- Provides typical imaging workflow including worklists
- Fully-coded form for reporting chest radiographs with free text impressions
- FHIR DiagnosticReport and ImagingStudy GET interfaces
- PDF report generation is also provided
- Summary E-mail reporting for a given time period
- Quality Improvement/Overread support
- OpenMRS integration for demographic queries

Configuration
=============
Rails stores configuraiton as .yml files in config/  .yml.dist files are provided as a starting point.  

database.yml - standard rails database configuration file
openmrs.yml - configures the integration with an OpenMRS instance
dcm4chee.yml - if you're using a dcm4chee archive to store DICOM data
email.yml - e-mail server settings, and distibution lists are defined here

Docker
======
After cloning the github repo you will need to build your containers.

`docker-compose build`

Once the containers are successfully built, create the rails configuration files.  Minimum required configuration files are database.yml and openmrs.yml.

`cp config/database.yml.docker config/database.yml`

`cp config/openmrs.yml.dist config/openmrs.yml`

Next, we can run the rake scripts to create the mysql databases and tables:

`docker-compose run web rake db:setup`

We can load the database with a small amount of test data as defined in test/fixtures

`docker-compose run web rake db:fixtures:load`

At this point you should be able to browse to http://localhost:3000/ and login using username: admin and password: password.

The rails console is a particulary helpful tool, which allows you to interactively run rails code against your database.

`docker-compose run web rails c`