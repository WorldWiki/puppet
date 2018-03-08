<?php

// Database passwords
$wgDBname = "<%= @mediawiki_dbname %>";
$wgDBuser = "<%= @mediawiki_user %>";
$wgDBpassword = "<%= @mediawiki_password %>";

// MediaWiki secret keys
$wgUpgradeKey = "<%= @mediawiki_upgradekey %>";
$wgSecretKey = "<%= @mediawiki_secretkey %>";


$wgReCaptchaSiteKey = "<%= @mediawiki_recaptcha_public_key %>";

$wgReCaptchaSecretKey = "<%= @mediawiki_recaptcha_private_key %>";
