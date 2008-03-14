<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my @main_menu = ();
push(@main_menu, { icon => "buttons/bt_config",
  label => "_SYSTEM_CONFIG", link => "./system.asp" })
  if ($Session->{AAT_ROLE} =~ /admin/i);

push(@main_menu,
  { icon => "buttons/bt_alert", 
		label => "_ALERTS", link => "./alerts.asp" },
  { icon => "buttons/bt_contact", 
		label => "_CONTACTS", link => "./contacts.asp" },
  { icon => "buttons/bt_device", 
		label => "_DEVICES", link => "./devices.asp" },
  { icon => "buttons/bt_device", 
		label => "_DEVICEGROUPS", link => "./devicegroups.asp" },
  { icon => "buttons/bt_home", 
		label => "_LOCATIONS", link => "./locations.asp" },
  { icon => "buttons/bt_location", 
		label => "_MAPS", popup_link => "./maps.asp" },
  { icon => "buttons/bt_messages", 
		label => "_MESSAGES", link => "./messages.asp" },
  { icon => "buttons/bt_report", 
		label => "_REPORTS", link => "./reports.asp" },
#  { icon => "reports", label => "_STATISTIC_REPORTS",
#    link => buttons/"./statistic_reports.asp" },
  { icon => "buttons/bt_scheduler", 
		label => "_SCHEDULER", link => "./scheduler.asp" },
  { icon => "buttons/bt_service", 
		label => "_SERVICES", link => "./services.asp" },
# 	{ icon => "buttons/bt_servicegroup", 
#		label => "_SERVICEGROUPS", link => "./servicegroups.asp" },
	{ icon => "buttons/bt_storage",
   	label => "_STORAGES", link => "./storages.asp" },
  { icon => "buttons/bt_table", 
		label => "_TABLES", link => "./tables.asp" },
  { icon => "buttons/bt_period", 
		label => "_TIMEPERIODS", link => "./timeperiods.asp" },
  { icon => "buttons/bt_users", label => "_USERS", link => "./user.asp" },
  { separator => 1 },
  { icon => "buttons/bt_alert", 
		label => "_ALERTS_VIEWER", link => "./alerts_viewer.asp" },
  { icon => "buttons/bt_search", label => "_LOGS_VIEWER",
    link => "./logs_viewer.asp" },
  { icon => "buttons/bt_report", label => "_REPORTS_VIEWER",
    link => "./reports_viewer.asp" },
  { separator => 1 },
  { icon => "buttons/bt_wizard", 
		label => "_LOGS_WIZARD", link => "./wizard.asp" },
  { separator => 1 },
  { icon => "buttons/bt_bug", 
		label => "_SUPPORT_REQUEST", link => "./bugreport.asp" });

$Response->Include('AAT/INC/AAT_Menu.inc', items => \@main_menu);
%>