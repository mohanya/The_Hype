CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `item_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `delayed_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `priority` int(11) DEFAULT '0',
  `attempts` int(11) DEFAULT '0',
  `handler` text COLLATE utf8_unicode_ci,
  `last_error` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `email_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `body` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `subject` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `friendships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `friend_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `invites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `inviter_id` int(11) DEFAULT NULL,
  `used` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `approved` tinyint(1) DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `item_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `image_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image_height` int(11) DEFAULT NULL,
  `image_width` int(11) DEFAULT NULL,
  `comments_count` int(11) DEFAULT NULL,
  `score` float DEFAULT NULL,
  `last_hyped_at` datetime DEFAULT NULL,
  `criteria_1` float DEFAULT NULL,
  `criteria_2` float DEFAULT NULL,
  `criteria_3` float DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `hype_worth` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `peer_reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `review_id` int(11) DEFAULT NULL,
  `helpful_review` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `permalink` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `posted_at` datetime DEFAULT NULL,
  `body` text COLLATE utf8_unicode_ci,
  `author_id` int(11) DEFAULT NULL,
  `comments_count` int(11) DEFAULT NULL,
  `state` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'draft',
  `page_title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` varchar(155) COLLATE utf8_unicode_ci DEFAULT NULL,
  `keywords` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `referral_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `subscribed` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `avatar_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `avatar_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `avatar_file_size` int(11) DEFAULT NULL,
  `job` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `income` int(11) DEFAULT NULL,
  `married` tinyint(1) DEFAULT NULL,
  `consumer_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `trusted_brands` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `computer` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `automobile` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mobile_phone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `band` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `book` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `movie` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `destination` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tos` tinyint(1) DEFAULT NULL,
  `peer_review_score` float DEFAULT NULL,
  `hyper_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `follower_notice` tinyint(1) DEFAULT '1',
  `comment_notice` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_profiles_on_email` (`email`),
  KEY `index_profiles_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `item_id` int(11) DEFAULT NULL,
  `criteria_1` int(11) DEFAULT NULL,
  `criteria_2` int(11) DEFAULT NULL,
  `criteria_3` int(11) DEFAULT NULL,
  `comments` text COLLATE utf8_unicode_ci,
  `recommended` tinyint(1) DEFAULT NULL,
  `shared` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `site_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `beta_invites` tinyint(1) DEFAULT '0',
  `admin_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `referrals` tinyint(1) DEFAULT '0',
  `blog` tinyint(1) DEFAULT '0',
  `newsletter` tinyint(1) DEFAULT '0',
  `user_avatar_upload` tinyint(1) DEFAULT NULL,
  `allow_blog` tinyint(1) DEFAULT NULL,
  `cm_api_key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `cm_subscribers_list` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `sitemap_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `xml_location` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `username` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `password` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `sitemap_static_links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `priority` float DEFAULT NULL,
  `frequency` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `section` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `sitemap_widgets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `widget_model` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `index_named_route` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `frequency_index` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `frequency_show` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `priority` float DEFAULT NULL,
  `custom_finder` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `slugs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sluggable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sluggable_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `sequence` int(11) NOT NULL DEFAULT '1',
  `scope` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_slugs_on_n_s_s_and_s` (`name`,`sluggable_type`,`scope`,`sequence`),
  KEY `index_slugs_on_sluggable_id` (`sluggable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `subscriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `profile_id` int(11) DEFAULT NULL,
  `subscribed_at` datetime DEFAULT NULL,
  `signup_ip_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `taggings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) DEFAULT NULL,
  `taggable_id` int(11) DEFAULT NULL,
  `tagger_id` int(11) DEFAULT NULL,
  `tagger_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `taggable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `context` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_taggings_on_tag_id` (`tag_id`),
  KEY `index_taggings_on_taggable_id_and_taggable_type_and_context` (`taggable_id`,`taggable_type`,`context`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crypted_password` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `salt` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `remember_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `remember_token_expires_at` datetime DEFAULT NULL,
  `activation_code` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `activated_at` datetime DEFAULT NULL,
  `state` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'passive',
  `deleted_at` datetime DEFAULT NULL,
  `admin` tinyint(1) DEFAULT NULL,
  `password_reset_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `invites` int(11) DEFAULT '3',
  `sent_activation` tinyint(1) DEFAULT NULL,
  `time_zone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `fb_user_id` bigint(20) DEFAULT NULL,
  `email_hash` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('20080405174119');

INSERT INTO schema_migrations (version) VALUES ('20080406040121');

INSERT INTO schema_migrations (version) VALUES ('20080406064155');

INSERT INTO schema_migrations (version) VALUES ('20080406072209');

INSERT INTO schema_migrations (version) VALUES ('20080407035224');

INSERT INTO schema_migrations (version) VALUES ('20080409061933');

INSERT INTO schema_migrations (version) VALUES ('20080424160320');

INSERT INTO schema_migrations (version) VALUES ('20080426180601');

INSERT INTO schema_migrations (version) VALUES ('20080626020518');

INSERT INTO schema_migrations (version) VALUES ('20080628054235');

INSERT INTO schema_migrations (version) VALUES ('20080815192916');

INSERT INTO schema_migrations (version) VALUES ('20080905054526');

INSERT INTO schema_migrations (version) VALUES ('20080930222710');

INSERT INTO schema_migrations (version) VALUES ('20081001003702');

INSERT INTO schema_migrations (version) VALUES ('20081013052523');

INSERT INTO schema_migrations (version) VALUES ('20081013194528');

INSERT INTO schema_migrations (version) VALUES ('20081023030155');

INSERT INTO schema_migrations (version) VALUES ('20081024222158');

INSERT INTO schema_migrations (version) VALUES ('20081025063032');

INSERT INTO schema_migrations (version) VALUES ('20081026115820');

INSERT INTO schema_migrations (version) VALUES ('20081031100020');

INSERT INTO schema_migrations (version) VALUES ('20081031120020');

INSERT INTO schema_migrations (version) VALUES ('20081125203750');

INSERT INTO schema_migrations (version) VALUES ('20090112042633');

INSERT INTO schema_migrations (version) VALUES ('20090216165308');

INSERT INTO schema_migrations (version) VALUES ('20090221122234');

INSERT INTO schema_migrations (version) VALUES ('20090222071032');

INSERT INTO schema_migrations (version) VALUES ('20090310194958');

INSERT INTO schema_migrations (version) VALUES ('20090512233128');

INSERT INTO schema_migrations (version) VALUES ('20090513045313');

INSERT INTO schema_migrations (version) VALUES ('20090513055255');

INSERT INTO schema_migrations (version) VALUES ('20090531234543');

INSERT INTO schema_migrations (version) VALUES ('20090601060418');

INSERT INTO schema_migrations (version) VALUES ('20090601124113');

INSERT INTO schema_migrations (version) VALUES ('20090601124729');

INSERT INTO schema_migrations (version) VALUES ('20090601182823');

INSERT INTO schema_migrations (version) VALUES ('20090609002536');

INSERT INTO schema_migrations (version) VALUES ('20090609012020');

INSERT INTO schema_migrations (version) VALUES ('20090614002016');

INSERT INTO schema_migrations (version) VALUES ('20090614002555');

INSERT INTO schema_migrations (version) VALUES ('20090614002657');

INSERT INTO schema_migrations (version) VALUES ('20090629191435');

INSERT INTO schema_migrations (version) VALUES ('20090713233659');

INSERT INTO schema_migrations (version) VALUES ('20090714091830');

INSERT INTO schema_migrations (version) VALUES ('20090715085613');

INSERT INTO schema_migrations (version) VALUES ('20090716081518');

INSERT INTO schema_migrations (version) VALUES ('20090716160154');

INSERT INTO schema_migrations (version) VALUES ('20100226174044');

INSERT INTO schema_migrations (version) VALUES ('20100413205506');