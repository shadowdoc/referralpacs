/* Create.sql for ReferralonRails
 * Marc Kohli
 * For all of the created/modified timestamps, the names have changed to take
 * advantage of Rails.
 */

drop table if exists encounters;

create table encounters (
	id                 int         not null auto_increment,
	encounter_date datetime    not null,
	patient_id    int          not null,
	study_id       int         not null,
	requester_id   int         not null,
	indication     varchar(100)        not null,
	findings       varchar(100)        not null,
	impression     varchar(100)        not null,
	radiologist_id int         not null,
	xray_id        int         not null,
	invoice        int         not null,
	user_created   int         not null,
	created_on     datetime    not null,
	user_modified  int         not null,
	modified_on  datetime    not null,
	primary key (id)
);

drop table if exists patients;

create table patients (
	id             int          not null auto_increment,
    given_name     varchar(100) not null,
    last_name      varchar(100) not null,
    middle_name    varchar(100) not null,    
	user_created   int          not null,
	created_on     datetime     not null,
	user_modified  int          not null,
	modified_on    datetime     not null,
	primary key (id)
);

drop table if exists users;

create table users (
    id              int         not null auto_increment,
    name            varchar(100),
    hashed_password varchar(100)        not null,
    email           varchar(100)        not null,
    access_level_id int,
    provider_id     int,
	user_created    int,
	created_on      datetime,
	user_modified   int,
	modified_on     datetime,
	primary key (id)
);

drop table if exists patients;

create table patients (
    /* mtrh_rad_id has become id */
    
    id                      int         not null auto_increment,
    mrn_ampath              int,
    mrn_mtrh_ip             int,
    mrn_mtrh_op             varchar(100),
    national_identifier     int,
    prefix                  varchar(50),
    given_name              varchar(100),
    middle_name             varchar(100),
    family_name             varchar(100),
    last_name_prefix        varchar(50),
    gender                  varchar(25),
    race                    varchar(100),
    tribe                   int,
    address1                varchar(100),
    address2                varchar(100),
    address_city_village    varchar(100),
    address_sublocation     varchar(100),
    address_location        varchar(100),
    address_division        varchar(100),
    address_district        varchar(100),
    address_state_province  varchar(100),
    adddres_country         varchar(100),
    address_zipcode         varchar(100),
    addressLongitude        float,
    addressLattitude        float,
    primary_phone           int,
    birthdate               datetime,
    birthdate_estimated     bool,
    birthplace              varchar(100),
    citizenship             varchar(100),
    civil_status            int,
    degree                  varchar(100),
    health_center           int,
    death_date              datetime,
    cause_of_death          time,
    user_created            int,
    date_created            datetime,
    user_modified           int,
    date_modified           timestamp,
    primary key (id)
);
    