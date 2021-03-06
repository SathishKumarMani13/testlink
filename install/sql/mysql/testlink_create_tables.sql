# TestLink Open Source Project - http://testlink.sourceforge.net/
# This script is distributed under the GNU General Public License 2 or later.
# ---------------------------------------------------------------------------------------
# @filesource testlink_create_tables.sql
#
# SQL script - create all DB tables for MySQL - InnoDB
#
# ATTENTION: do not use a different naming convention, that one already in use.
#
# IMPORTANT NOTE:
# each NEW TABLE added here NEED TO BE DEFINED in object.class.php getDBTables()
#
# IMPORTANT NOTE - DATETIME or TIMESTAMP
# Extracted from MySQL Manual
#
# The TIMESTAMP column type provides a type that you can use to automatically 
# mark INSERT or UPDATE operations with the current date and time. 
# If you have multiple TIMESTAMP columns in a table, only the first one is updated automatically.
#
# Knowing this is clear that we can use in interchangable way DATETIME or TIMESTAMP
#
# Naming convention for column regarding date/time of creation or change
#
# Right or wrong from TL 1.7 we have used
#
# creation_ts
# modification_ts
#
# Then no other naming convention has to be used as:
# create_ts, modified_ts
#
# CRITIC:
# Because this file will be processed during installation doing text replaces
# to add TABLE PREFIX NAME, any NEW DDL CODE added must be respect present
# convention regarding case and spaces between DDL keywords.
# 
# ---------------------------------------------------------------------------------------
# @internal revisions
# @since 2.0
# 20120906 - franciscom - TICKET 
# ---------------------------------------------------------------------------------------
#
#
CREATE TABLE /*prefix*/node_types (
  `id` int(10) unsigned NOT NULL auto_increment,
  `description` varchar(100) NOT NULL default 'testproject',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/nodes_hierarchy (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(100) default NULL,
  `parent_id` int(10) unsigned default NULL,
  `node_type_id` int(10) unsigned NOT NULL default '1',
  `node_order` int(10) unsigned default NULL,
  PRIMARY KEY  (`id`), 
  KEY /*prefix*/pid_m_nodeorder (`parent_id`,`node_order`),
  CONSTRAINT /*prefix*/nodes_hierarchy_node_types_fk 
  FOREIGN KEY (`node_type_id`) REFERENCES /*prefix*/node_types (id) 
  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/transactions (
  `id` int(10) unsigned NOT NULL auto_increment,
  `entry_point` varchar(45) NOT NULL default '',
  `start_time` int(10) unsigned NOT NULL default '0',
  `end_time` int(10) unsigned NOT NULL default '0',
  `user_id` int(10) unsigned NOT NULL default '0',
  `session_id` varchar(45) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/events (
  `id` int(10) unsigned NOT NULL auto_increment,
  `transaction_id` int(10) unsigned NOT NULL default '0',
  `log_level` smallint(5) unsigned NOT NULL default '0',
  `source` varchar(45) default NULL,
  `description` text NOT NULL,
  `fired_at` int(10) unsigned NOT NULL default '0',
  `activity` varchar(45) default NULL,
  `object_id` int(10) unsigned default NULL,
  `object_type` varchar(45) default NULL,
  PRIMARY KEY  (`id`),
  KEY /*prefix*/transaction_id (`transaction_id`),
  KEY /*prefix*/fired_at (`fired_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/roles (
  `id` int(10) unsigned NOT NULL auto_increment,
  `description` varchar(100) NOT NULL default '',
  `notes` text,
  PRIMARY KEY  (`id`),
  UNIQUE KEY /*prefix*/role_rights_roles_descr (`description`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/users (
  `id` int(10) unsigned NOT NULL auto_increment,
  `login` varchar(30) NOT NULL default '',
  `password` varchar(32) NOT NULL default '',
  `role_id` int(10) unsigned NOT NULL default '0',
  `email` varchar(100) NOT NULL default '',
  `first` varchar(30) NOT NULL default '',
  `last` varchar(30) NOT NULL default '',
  `locale` varchar(10) NOT NULL default 'en_GB',
  `default_testproject_id` int(10) default NULL,
  `active` tinyint(1) NOT NULL default '1',
  `script_key` varchar(32) NULL,
  `cookie_string` varchar(64) NOT NULL DEFAULT '',  
  PRIMARY KEY  (`id`),
  UNIQUE KEY /*prefix*/users_login (`login`),
  UNIQUE KEY /*prefix*/users_cookie_string (`cookie_string`),
  CONSTRAINT /*prefix*/users_roles_fk 
  FOREIGN KEY (`role_id`) REFERENCES /*prefix*/roles (id) 
  ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='User information';


CREATE TABLE /*prefix*/tcversions (
  `id` int(10) unsigned NOT NULL,
  `tc_external_id` int(10) unsigned NULL,
  `version` smallint(5) unsigned NOT NULL default '1',
  `layout` smallint(5) unsigned NOT NULL default '1',
  `status` smallint(5) unsigned NOT NULL default '1',
  `summary` text,
  `preconditions` text,
  `importance` smallint(5) unsigned NOT NULL default '2',
  `author_id` int(10) unsigned default NULL,
  `creation_ts` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater_id` int(10) unsigned default NULL,
  `modification_ts` datetime NOT NULL default '0000-00-00 00:00:00',
  `active` tinyint(1) NOT NULL default '1',
  `is_open` tinyint(1) NOT NULL default '1',
  `execution_type` tinyint(1) NOT NULL default '1' COMMENT '1 -> manual, 2 -> automated',
  `estimated_execution_duration` decimal(6,2) NULL COMMENT 'NULL will be considered as NO DATA Provided by user',
  PRIMARY KEY  (`id`), 
  CONSTRAINT /*prefix*/tcversions_nodes_hierarchy_fk 
  FOREIGN KEY (`id`) REFERENCES /*prefix*/nodes_hierarchy (id) 
  ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/tcversions_author_users_fk 
  FOREIGN KEY (`author_id`) REFERENCES /*prefix*/users (id) 
  ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/tcversions_updater_users_fk 
  FOREIGN KEY (`updater_id`) REFERENCES /*prefix*/users (id) 
  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/tcsteps (  
  id int(10) unsigned NOT NULL,
  step_number INT NOT NULL DEFAULT '1',
  actions TEXT,
  expected_results TEXT,
  active tinyint(1) NOT NULL default '1',
  execution_type tinyint(1) NOT NULL default '1' COMMENT '1 -> manual, 2 -> automated',
  PRIMARY KEY (id), 
  CONSTRAINT /*prefix*/tcsteps_nodes_hierarchy_fk 
  FOREIGN KEY (`id`) REFERENCES /*prefix*/nodes_hierarchy (id) 
  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/testplans (
  `id` int(10) unsigned NOT NULL,
  `testproject_id` int(10) unsigned NOT NULL default '0',
  `notes` text,
  `active` tinyint(1) NOT NULL default '1',
  `is_open` tinyint(1) NOT NULL default '1',
  `is_public` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`id`), 
  KEY /*prefix*/testplans_testproject_id_active (`testproject_id`,`active`),
  CONSTRAINT /*prefix*/testplans_nodes_hierarchy_fk 
  FOREIGN KEY (`id`) REFERENCES /*prefix*/nodes_hierarchy (id) 
  ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/builds (
  `id` int(10) unsigned NOT NULL auto_increment,
  `testplan_id` int(10) unsigned NOT NULL default '0',
  `name` varchar(100) NOT NULL default 'undefined',
  `notes` text,
  `active` tinyint(1) NOT NULL default '1',
  `is_open` tinyint(1) NOT NULL default '1',
  `author_id` int(10) unsigned default NULL,
  `creation_ts` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `release_date` date NULL,
  `closed_on_date` date NULL,
  PRIMARY KEY  (`id`), 
  UNIQUE KEY /*prefix*/name (`testplan_id`,`name`),
  CONSTRAINT /*prefix*/builds_testplans_fk 
  FOREIGN KEY (`testplan_id`) REFERENCES /*prefix*/testplans (id) 
  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Available builds';


CREATE TABLE /*prefix*/executions (
  id int(10) unsigned NOT NULL auto_increment,
  build_id int(10) unsigned NOT NULL default '0',
  tester_id int(10) unsigned default NULL,
  execution_ts datetime default NULL,
  status char(1) default NULL,
  testplan_id int(10) unsigned NOT NULL default '0',
  tcversion_id int(10) unsigned NOT NULL default '0',
  tcversion_number smallint(5) unsigned NOT NULL default '1',
  platform_id int(10) unsigned NOT NULL default '0',
  execution_type tinyint(1) NOT NULL default '1' COMMENT '1 -> manual, 2 -> automated',
  execution_duration decimal(6,2) NULL COMMENT 'NULL will be considered as NO DATA Provided by user',
  notes text,
  PRIMARY KEY  (id), 
  KEY /*prefix*/testplan_id_tcversion_id(testplan_id,tcversion_id),
  KEY /*prefix*/execution_type(execution_type),
  CONSTRAINT /*prefix*/executions_builds_fk 
  FOREIGN KEY (`build_id`) REFERENCES /*prefix*/builds (id) 
  ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/executions_testplans_fk 
  FOREIGN KEY (`testplan_id`) REFERENCES /*prefix*/testplans (id) 
  ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/executions_tcversions_fk 
  FOREIGN KEY (`tcversion_id`) REFERENCES /*prefix*/tcversions (id) 
  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/testplan_tcversions (
  id int(10) unsigned NOT NULL auto_increment,
  testplan_id int(10) unsigned NOT NULL default '0',
  tcversion_id int(10) unsigned NOT NULL default '0',
  node_order int(10) unsigned NOT NULL default '1',
  urgency smallint(5) NOT NULL default '2',
  platform_id int(10) unsigned NOT NULL default '0',
  author_id int(10) unsigned default NULL,
  creation_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY  (id),
  UNIQUE KEY /*prefix*/testplan_tcversions_tplan_tcversion (testplan_id,tcversion_id,platform_id),
  CONSTRAINT /*prefix*/testplan_tcversions_testplans_fk 
  FOREIGN KEY (`testplan_id`) REFERENCES /*prefix*/testplans (id) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/testplan_tcversions_tcversions_fk 
  FOREIGN KEY (`tcversion_id`) REFERENCES /*prefix*/tcversions (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/custom_fields (
  `id` int(10) NOT NULL auto_increment,
  `name` varchar(64) NOT NULL default '',
  `label` varchar(64) NOT NULL default '' COMMENT 'label to display on user interface' ,
  `type` smallint(6) NOT NULL default '0',
  `possible_values` varchar(4000) NOT NULL default '',
  `default_value` varchar(4000) NOT NULL default '',
  `valid_regexp` varchar(255) NOT NULL default '',
  `length_min` int(10) NOT NULL default '0',
  `length_max` int(10) NOT NULL default '0',
  `show_on_design` tinyint(3) unsigned NOT NULL default '1' COMMENT '1=> show it during specification design',
  `enable_on_design` tinyint(3) unsigned NOT NULL default '1' COMMENT '1=> user can write/manage it during specification design',
  `show_on_execution` tinyint(3) unsigned NOT NULL default '0' COMMENT '1=> show it during test case execution',
  `enable_on_execution` tinyint(3) unsigned NOT NULL default '0' COMMENT '1=> user can write/manage it during test case execution',
  `show_on_testplan_design` tinyint(3) unsigned NOT NULL default '0' ,
  `enable_on_testplan_design` tinyint(3) unsigned NOT NULL default '0' ,
  `required` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  UNIQUE KEY /*prefix*/idx_custom_fields_name (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/testprojects (
  `id` int(10) unsigned NOT NULL,
  `notes` text,
  `color` varchar(12) NOT NULL default '#9BD',
  `active` tinyint(1) NOT NULL default '1',
  `option_reqs` tinyint(1) NOT NULL default '0',
  `option_priority` tinyint(1) NOT NULL default '0',
  `option_automation` tinyint(1) NOT NULL default '0',  
  `options` text,
  `prefix` varchar(16) NOT NULL,
  `tc_counter` int(10) unsigned NOT NULL default '0',
  `is_public` tinyint(1) NOT NULL default '1',
  `issue_tracker_enabled` tinyint(1) NOT NULL default '0',
  `author_id` int(10) unsigned default NULL,
  `creation_ts` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater_id` int(10) unsigned default NULL,
  `modification_ts` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`), 
  KEY /*prefix*/testprojects_id_active (`id`,`active`),
  UNIQUE KEY /*prefix*/testprojects_prefix (`prefix`),
  CONSTRAINT /*prefix*/testprojects_nodes_hierarchy_fk 
  FOREIGN KEY (`id`) REFERENCES /*prefix*/nodes_hierarchy (id) 
  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/cfield_testprojects (
  `field_id` int(10) NOT NULL default '0',
  `testproject_id` int(10) unsigned NOT NULL default '0',
  `display_order` smallint(5) unsigned NOT NULL default '1',
  `location` smallint(5) unsigned NOT NULL default '1',
  `active` tinyint(1) NOT NULL default '1',
  `required_on_design` tinyint(1) NOT NULL default '0',
  `required_on_execution` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`field_id`,`testproject_id`), 
  CONSTRAINT /*prefix*/cfield_testprojects_custom_fields_fk 
  FOREIGN KEY (`field_id`) REFERENCES /*prefix*/custom_fields (id) 
  ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/cfield_testprojects_testprojects_fk 
  FOREIGN KEY (`testproject_id`) REFERENCES /*prefix*/testprojects (id) 
  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/cfield_design_values (
  `field_id` int(10) NOT NULL default '0',
  `node_id` int(10) unsigned NOT NULL default '0',
  `value` varchar(4000) NOT NULL default '',
  PRIMARY KEY  (`field_id`,`node_id`),
  CONSTRAINT /*prefix*/cfield_design_values_custom_fields_fk 
  FOREIGN KEY (`field_id`) REFERENCES /*prefix*/custom_fields (id) 
  ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/cfield_design_values_nodes_hierarchy_fk 
  FOREIGN KEY (`node_id`) REFERENCES /*prefix*/nodes_hierarchy (id) 
  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/cfield_execution_values (
  `field_id`     int(10) NOT NULL default '0',
  `execution_id` int(10) unsigned NOT NULL default '0',
  `testplan_id` int(10) unsigned NOT NULL default '0',
  `tcversion_id` int(10) unsigned NOT NULL default '0',
  `value` varchar(4000) NOT NULL default '',
  PRIMARY KEY  (`field_id`,`execution_id`,`testplan_id`,`tcversion_id`), 
  CONSTRAINT /*prefix*/cfield_execution_values_custom_fields_fk 
  FOREIGN KEY (`field_id`) REFERENCES /*prefix*/custom_fields (id) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/cfield_execution_values_executions_fk 
  FOREIGN KEY (`execution_id`) REFERENCES /*prefix*/executions (id) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/cfield_execution_values_testplans_fk 
  FOREIGN KEY (`testplan_id`) REFERENCES /*prefix*/testplans (id) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/cfield_execution_values_tcversions_fk 
  FOREIGN KEY (`tcversion_id`) REFERENCES /*prefix*/tcversions (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/cfield_testplan_design_values (
  `field_id` int(10) NOT NULL default '0',
  `link_id` int(10) unsigned NOT NULL default '0' COMMENT 'point to testplan_tcversion id',   
  `value` varchar(4000) NOT NULL default '',
  PRIMARY KEY  (`field_id`,`link_id`),
  CONSTRAINT /*prefix*/cfield_testplan_design_values_custom_fields_fk 
  FOREIGN KEY (`field_id`) REFERENCES /*prefix*/custom_fields (id) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/cfield_testplan_design_values_testplan_tcversions_fk 
  FOREIGN KEY (`link_id`) REFERENCES /*prefix*/testplan_tcversions (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/cfield_node_types (
  `field_id` int(10) NOT NULL default '0',
  `node_type_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`field_id`,`node_type_id`),
  CONSTRAINT /*prefix*/cfield_node_types_custom_fields_fk 
  FOREIGN KEY (`field_id`) REFERENCES /*prefix*/custom_fields (id) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/cfield_node_types_node_types_fk 
  FOREIGN KEY (`node_type_id`) REFERENCES /*prefix*/node_types (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/assignment_status (
  `id` int(10) unsigned NOT NULL auto_increment,
  `description` varchar(100) NOT NULL default 'unknown',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/assignment_types (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_table` varchar(30) default '',
  `description` varchar(100) NOT NULL default 'unknown',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/attachments (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_id` int(10) unsigned NOT NULL default '0',
  `fk_table` varchar(250) default '',
  `title` varchar(250) default '',
  `description` varchar(250) default '',
  `file_name` varchar(250) NOT NULL default '',
  `file_path` varchar(250) default '',
  `file_size` int(11) NOT NULL default '0',
  `file_type` varchar(250) NOT NULL default '',
  `date_added` datetime NOT NULL default '0000-00-00 00:00:00',
  `content` longblob,
  `compression_type` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8; 


CREATE TABLE /*prefix*/db_version (
  `version` varchar(50) NOT NULL default 'unknown',
  `upgrade_ts` datetime NOT NULL default '0000-00-00 00:00:00',
  `notes` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/execution_bugs (
  `execution_id` int(10) unsigned NOT NULL default '0',
  `bug_id` varchar(16) NOT NULL default '0',
  PRIMARY KEY  (`execution_id`,`bug_id`), 
  CONSTRAINT /*prefix*/execution_bugs_executions_fk 
  FOREIGN KEY (`execution_id`) REFERENCES /*prefix*/executions (id) 
  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE /*prefix*/keywords (
  `id` int(10) unsigned NOT NULL auto_increment,
  `keyword` varchar(100) NOT NULL default '',
  `testproject_id` int(10) unsigned NOT NULL default '0',
  `notes` text,
  PRIMARY KEY  (`id`), 
  KEY /*prefix*/keyword (`keyword`),
  CONSTRAINT /*prefix*/keywords_testprojects_fk 
  FOREIGN KEY (`testproject_id`) REFERENCES /*prefix*/testprojects (id) 
  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/milestones (
  id int(10) unsigned NOT NULL auto_increment,
  testplan_id int(10) unsigned NOT NULL default '0',
  target_date date NULL,
  start_date date NOT NULL default '0000-00-00',
  a tinyint(3) unsigned NOT NULL default '0',
  b tinyint(3) unsigned NOT NULL default '0',
  c tinyint(3) unsigned NOT NULL default '0',
  name varchar(100) NOT NULL default 'undefined',
  PRIMARY KEY  (id),
  UNIQUE KEY /*prefix*/name_testplan_id (`name`,`testplan_id`),
  CONSTRAINT /*prefix*/milestones_testplans_fk 
  FOREIGN KEY (`testplan_id`) REFERENCES /*prefix*/testplans (id) 
  ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/object_keywords (
  `id` int(10) unsigned NOT NULL auto_increment,
  `fk_id` int(10) unsigned NOT NULL default '0',
  `fk_table` varchar(30) default '',
  `keyword_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`id`), 
  CONSTRAINT /*prefix*/object_keywords_keywords_fk 
  FOREIGN KEY (`keyword_id`) REFERENCES /*prefix*/keywords (id) 
  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8; 


# CREATE TABLE /*prefix*/req_specs (
#   `id` int(10) unsigned NOT NULL,
#   `testproject_id` int(10) unsigned NOT NULL,
#   `doc_id` varchar(64) NOT NULL,
#   `scope` text,
#   `total_req` int(10) NOT NULL default '0',
#   `type` char(1) default 'n',
#   `author_id` int(10) unsigned default NULL,
#    creation_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
#   `modifier_id` int(10) unsigned default NULL,
#   `modification_ts` datetime NOT NULL default '0000-00-00 00:00:00',
#   PRIMARY KEY  (`id`), 
#   UNIQUE KEY /*prefix*/req_spec_uk1(`doc_id`,`testproject_id`),
#   CONSTRAINT /*prefix*/req_specs_testprojects_fk 
#   FOREIGN KEY (`testproject_id`) REFERENCES /*prefix*/testprojects (id) 
#   ON DELETE CASCADE ON UPDATE CASCADE, 
#   CONSTRAINT /*prefix*/req_specs_nodes_hierarchy_fk 
#   FOREIGN KEY (`id`) REFERENCES /*prefix*/nodes_hierarchy (id) 
#   ON DELETE CASCADE ON UPDATE CASCADE 
# ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Dev. Documents (e.g. System Requirements Specification)';

# TICKET 4661
CREATE TABLE /*prefix*/req_specs (
  `id` int(10) unsigned NOT NULL,
  `testproject_id` int(10) unsigned NOT NULL,
  `doc_id` varchar(64) NOT NULL,
  `modification_ts` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`), 
  UNIQUE KEY /*prefix*/req_spec_uk1(`doc_id`,`testproject_id`),
  CONSTRAINT /*prefix*/req_specs_testprojects_fk 
  FOREIGN KEY (`testproject_id`) REFERENCES /*prefix*/testprojects (id) 
  ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/req_specs_nodes_hierarchy_fk 
  FOREIGN KEY (`id`) REFERENCES /*prefix*/nodes_hierarchy (id) 
  ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Dev. Documents (e.g. System Requirements Specification)';




CREATE TABLE /*prefix*/requirements (
  `id` int(10) unsigned NOT NULL,
  `srs_id` int(10) unsigned NOT NULL,
  `req_doc_id` varchar(64) NOT NULL,
  PRIMARY KEY  (`id`), 
  UNIQUE KEY /*prefix*/requirements_req_doc_id (`srs_id`,`req_doc_id`),
  CONSTRAINT /*prefix*/requirements_nodes_hierarchy_fk 
  FOREIGN KEY (`id`) REFERENCES /*prefix*/nodes_hierarchy (id) 
  ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/requirements_req_specs_fk 
  FOREIGN KEY (`srs_id`) REFERENCES /*prefix*/req_specs (id) 
  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/req_versions (
  `id` int(10) unsigned NOT NULL,
  `version` smallint(5) unsigned NOT NULL default '1', 
  `revision` smallint(5) unsigned NOT NULL default '1', 
  `scope` text,
  `status` char(1) NOT NULL default 'V',
  `type` char(1) default NULL,
  `active` tinyint(1) NOT NULL default '1',
  `is_open` tinyint(1) NOT NULL default '1',
  `expected_coverage` int(10) NOT NULL default '1',
  `author_id` int(10) unsigned default NULL,
  `creation_ts` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modifier_id` int(10) unsigned default NULL,
  `modification_ts` datetime NOT NULL default '0000-00-00 00:00:00',
  `log_message` text,
  PRIMARY KEY  (`id`,`version`), 
  CONSTRAINT /*prefix*/req_versions_nodes_hierarchy_fk 
  FOREIGN KEY (`id`) REFERENCES /*prefix*/nodes_hierarchy (id) 
  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/req_coverage (
  `req_id` int(10) unsigned NOT NULL,
  `testcase_id` int(10) NOT NULL, 
  KEY /*prefix*/req_testcase (`req_id`,`testcase_id`),
  CONSTRAINT /*prefix*/req_coverage_requirements_fk 
  FOREIGN KEY (`req_id`) REFERENCES /*prefix*/requirements (id) 
  ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='relation test case ** requirements';


CREATE TABLE /*prefix*/rights (
  `id` int(10) unsigned NOT NULL auto_increment,
  `description` varchar(100) NOT NULL default '',
  PRIMARY KEY  (`id`),
  UNIQUE KEY /*prefix*/rights_descr (`description`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/risk_assignments (
  `id` int(10) unsigned NOT NULL auto_increment,
  `testplan_id` int(10) unsigned NOT NULL default '0',
  `node_id` int(10) unsigned NOT NULL default '0',
  `risk` char(1) NOT NULL default '2',
  `importance` char(1) NOT NULL default 'M',
  PRIMARY KEY  (`id`),
  UNIQUE KEY /*prefix*/risk_assignments_tplan_node_id (`testplan_id`,`node_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/role_rights (
  `role_id` int(10) unsigned NOT NULL default '0',
  `right_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`role_id`,`right_id`), 
  CONSTRAINT /*prefix*/role_rights_roles_fk 
  FOREIGN KEY (`role_id`) REFERENCES /*prefix*/roles (id) 
  ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/role_rights_rights_fk 
  FOREIGN KEY (`right_id`) REFERENCES /*prefix*/rights (id) 
  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/testcase_keywords (
  `testcase_id` int(10) unsigned NOT NULL default '0',
  `keyword_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`testcase_id`,`keyword_id`), 
  CONSTRAINT /*prefix*/testcase_keywords_nodes_hierarchy_fk 
  FOREIGN KEY (`testcase_id`) REFERENCES /*prefix*/nodes_hierarchy (id) 
  ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/testcase_keywords_keywords_fk 
  FOREIGN KEY (`keyword_id`) REFERENCES /*prefix*/keywords (id) 
  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/testsuites (
  `id` int(10) unsigned NOT NULL,
  `details` text,
  `author_id` int(10) unsigned default NULL,
  `creation_ts` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater_id` int(10) unsigned default NULL,
  `modification_ts` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`), 
  CONSTRAINT /*prefix*/testsuites_nodes_hierarchy_fk 
  FOREIGN KEY (`id`) REFERENCES /*prefix*/nodes_hierarchy (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/user_assignments (
  `id` int(10) unsigned NOT NULL auto_increment,
  `type` int(10) unsigned NOT NULL default '1',
  `feature_id` int(10) unsigned NOT NULL default '0',
  `user_id` int(10) unsigned default '0',
  `build_id` int(10) unsigned default '0',
  `deadline_ts` datetime NULL,
  `assigner_id`  int(10) unsigned default '0',
  `creation_ts` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` int(10) unsigned default '1',
  PRIMARY KEY  (`id`), 
  KEY /*prefix*/user_assignments_feature_id (`feature_id`),
  CONSTRAINT /*prefix*/user_assignments_user_users_fk 
  FOREIGN KEY (`user_id`) REFERENCES /*prefix*/users (id) 
  ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/user_assignments_assigner_users_fk 
  FOREIGN KEY (`assigner_id`) REFERENCES /*prefix*/users (id) 
  ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/user_assignments_builds_fk 
  FOREIGN KEY (`build_id`) REFERENCES /*prefix*/builds (id) 
  ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/user_testplan_roles (
  `user_id` int(10) unsigned NOT NULL default '0',
  `testplan_id` int(10) unsigned NOT NULL default '0',
  `role_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`user_id`,`testplan_id`), 
  CONSTRAINT /*prefix*/user_testplan_roles_users_fk 
  FOREIGN KEY (`user_id`) REFERENCES /*prefix*/users (id) 
  ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/user_testplan_roles_testplans_fk 
  FOREIGN KEY (`testplan_id`) REFERENCES /*prefix*/testplans (id) 
  ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/user_testplan_roles_roles_fk 
  FOREIGN KEY (`role_id`) REFERENCES /*prefix*/builds (id) 
  ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/user_testproject_roles (
  `user_id` int(10) unsigned NOT NULL default '0',
  `testproject_id` int(10) unsigned NOT NULL default '0',
  `role_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`user_id`,`testproject_id`), 
  CONSTRAINT /*prefix*/user_testproject_roles_users_fk 
  FOREIGN KEY (`user_id`) REFERENCES /*prefix*/users (id) 
  ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/user_testproject_roles_testprojects_fk 
  FOREIGN KEY (`testproject_id`) REFERENCES /*prefix*/testprojects (id) 
  ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/user_testproject_roles_roles_fk 
  FOREIGN KEY (`role_id`) REFERENCES /*prefix*/roles (id) 
  ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/user_group (
  `id` int(10) unsigned NOT NULL auto_increment,
  `title` varchar(100) NOT NULL,
  `description` text,
  PRIMARY KEY  (`id`), 
  UNIQUE KEY /*prefix*/idx_user_group (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/user_group_assign (
  `usergroup_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL, 
  UNIQUE KEY /*prefix*/idx_user_group_assign (`usergroup_id`,`user_id`),
  CONSTRAINT /*prefix*/user_group_assign_user_group_fk 
  FOREIGN KEY (`usergroup_id`) REFERENCES /*prefix*/user_group (id) 
  ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/user_group_assign_users_fk 
  FOREIGN KEY (`user_id`) REFERENCES /*prefix*/users (id) 
  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/platforms (
  id int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  name varchar(100) NOT NULL,
  testproject_id int(10) UNSIGNED NOT NULL,
  notes text NOT NULL,
  PRIMARY KEY (id), 
  UNIQUE KEY /*prefix*/idx_platforms (testproject_id,name),
  CONSTRAINT /*prefix*/platforms_testprojects_fk 
  FOREIGN KEY (`testproject_id`) REFERENCES /*prefix*/testprojects (id) 
  ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/testplan_platforms (
  id int(10) unsigned NOT NULL auto_increment,
  testplan_id int(10) unsigned NOT NULL,
  platform_id int(10) unsigned NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY /*prefix*/idx_testplan_platforms(testplan_id,platform_id), 
  CONSTRAINT /*prefix*/testplan_platforms_testplans_fk 
  FOREIGN KEY (`testplan_id`) REFERENCES /*prefix*/testplans (id) 
  ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT /*prefix*/testplan_platforms_platforms_fk 
  FOREIGN KEY (`platform_id`) REFERENCES /*prefix*/platforms (id) 
  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Connects a testplan with platforms';


CREATE TABLE /*prefix*/inventory (
  id int(10) unsigned NOT NULL auto_increment,
	`testproject_id` INT( 10 ) UNSIGNED NOT NULL ,
	`owner_id` INT(10) UNSIGNED NOT NULL ,
	`name` VARCHAR(255) NOT NULL ,
	`ipaddress` VARCHAR(255)  NOT NULL ,
	`content` TEXT NULL ,
	`creation_ts` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`modification_ts` TIMESTAMP NOT NULL,
	PRIMARY KEY (`id`),
	CONSTRAINT /*prefix*/inventory_testprojects_fk 
	FOREIGN KEY (`testproject_id`) REFERENCES /*prefix*/testprojects (id) 
	ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8; 


CREATE TABLE /*prefix*/req_relations (
  `id` int(10) unsigned NOT NULL auto_increment,
  `source_id` int(10) unsigned NOT NULL,
  `destination_id` int(10) unsigned NOT NULL,
  `relation_type` smallint(5) unsigned NOT NULL default '1',
  `author_id` int(10) unsigned default NULL,
  `creation_ts` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`), 
  CONSTRAINT /*prefix*/req_relations_source_requirements_fk 
  FOREIGN KEY (`source_id`) REFERENCES /*prefix*/requirements (id) 
  ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT /*prefix*/req_relations_destination_requirements_fk 
  FOREIGN KEY (`destination_id`) REFERENCES /*prefix*/requirements (id) 
  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE /*prefix*/req_revisions (
  `parent_id` int(10) unsigned NOT NULL,
  `id` int(10) unsigned NOT NULL,
  `revision` smallint(5) unsigned NOT NULL default '1',
  `req_doc_id` varchar(64) NULL,   /* it's OK to allow a simple update query on code */
  `name` varchar(100) NULL,
  `scope` text,
  `status` char(1) NOT NULL default 'V',
  `type` char(1) default NULL,
  `active` tinyint(1) NOT NULL default '1',
  `is_open` tinyint(1) NOT NULL default '1',
  `expected_coverage` int(10) NOT NULL default '1',
  `log_message` text,
  `author_id` int(10) unsigned default NULL,
  `creation_ts` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modifier_id` int(10) unsigned default NULL,
  `modification_ts` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`), 
  UNIQUE KEY /*prefix*/req_revisions_uidx1 (`parent_id`,`revision`),
  CONSTRAINT /*prefix*/req_revisions_req_versions_fk 
  FOREIGN KEY (`parent_id`) REFERENCES  /*prefix*/req_versions (id) 
  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

# ----------------------------------------------------------------------------------
# TICKET 4661
# ----------------------------------------------------------------------------------
CREATE TABLE /*prefix*/req_specs_revisions (
  `parent_id` int(10) unsigned NOT NULL,
  `id` int(10) unsigned NOT NULL,
  `revision` smallint(5) unsigned NOT NULL default '1',
  `doc_id` varchar(64) NULL,   /* it's OK to allow a simple update query on code */
  `name` varchar(100) NULL,
  `scope` text,
  `total_req` int(10) NOT NULL default '0',  
  `status` int(10) unsigned default '1',
  `type` char(1) default NULL,
  `log_message` text,
  `author_id` int(10) unsigned default NULL,
  `creation_ts` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modifier_id` int(10) unsigned default NULL,
  `modification_ts` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`),
  UNIQUE KEY /*prefix*/req_specs_revisions_uidx1 (`parent_id`,`revision`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE /*prefix*/issuetrackers
(
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(100) NOT NULL,
  `type` int(10) default 0,
  `cfg` text,
  PRIMARY KEY  (`id`),
  UNIQUE KEY /*prefix*/issuetrackers_uidx1 (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE /*prefix*/testproject_issuetracker
(
  `testproject_id` int(10) unsigned NOT NULL REFERENCES /*prefix*/testprojects (id), 
  `issuetracker_id` int(10) unsigned NOT NULL REFERENCES /*prefix*/issuetrackers (id),
  UNIQUE KEY /*prefix*/testproject_issuetracker_uidx1 (`testproject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
