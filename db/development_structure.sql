CREATE TABLE `encounter_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `modality` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `created_by` int(11) default NULL,
  `modified_at` datetime default NULL,
  `modified_by` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `encounters` (
  `id` int(11) NOT NULL auto_increment,
  `date` datetime default NULL,
  `patient_id` int(11) default NULL,
  `indication` varchar(255) default NULL,
  `findings` varchar(255) default NULL,
  `impression` varchar(255) default NULL,
  `created_by` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_by` int(11) default NULL,
  `updated_at` datetime default NULL,
  `encounter_type_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `patients` (
  `id` int(11) NOT NULL auto_increment,
  `mrn_ampath` int(11) default NULL,
  `national_identifier` int(11) default NULL,
  `prefix` varchar(255) default NULL,
  `given_name` varchar(255) default NULL,
  `middle_name` varchar(255) default NULL,
  `family_name` varchar(255) default NULL,
  `last_name_prefix` varchar(255) default NULL,
  `gender` varchar(255) default NULL,
  `race` varchar(255) default NULL,
  `tribe` int(11) default NULL,
  `address1` varchar(255) default NULL,
  `address2` varchar(255) default NULL,
  `created_by` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_by` int(11) default NULL,
  `updated_at` datetime default NULL,
  `birthdate` datetime default NULL,
  `mtrh_rad_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `privileges` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `view_study` tinyint(1) default NULL,
  `add_study` tinyint(1) default NULL,
  `remove_study` tinyint(1) default NULL,
  `add_patient` tinyint(1) default NULL,
  `remove_patient` tinyint(1) default NULL,
  `add_user` tinyint(1) default NULL,
  `remove_user` tinyint(1) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `hashed_password` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `provider_id` int(11) default NULL,
  `created_by` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_by` int(11) default NULL,
  `updated_at` datetime default NULL,
  `privilege_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_info (version) VALUES (7)