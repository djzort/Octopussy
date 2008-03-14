<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;

my $url = $arg{url};
my $sort = defined $arg{sort} ? lc($arg{sort}) : "name";
my $role = $Session->{AAT_ROLE};
my $lnk = "./devices.asp?devices_table_sort";
my @dconfs = Octopussy::Device::Filtered_Configurations($arg{dtype}, $arg{dmodel}, $sort);
my $reload = 0;
foreach my $d (@dconfs)
	{ $reload = 1	if (AAT::NOT_NULL($d->{reload_required})); }
%>
<AAT:Box align="C" title="_DEVICES" icon="buttons/bt_device">
<AAT:BoxRow>
	<AAT:BoxCol><%
	if ($reload)
	{ %><AAT:Button name="reload" tooltip="_RELOAD_ALL" 
		link="./devices.asp?action=parse_reload_all" /><% } 
%></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="_NAME" link="$lnk=name" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="_IP_ADDRESS" link="$lnk=address" /></AAT:BoxCol>	
	<AAT:BoxCol>
	<AAT:Label value="_LOG_TYPE" link="$lnk=logtype" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="_DEVICE_TYPE" link="$lnk=type" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="_DEVICE_MODEL" link="$lnk=model" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="_DESCRIPTION" link="$lnk=description" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="_STATUS" tooltip="_TOOLTIP_DEVICE_STATUS" 
		link="$lnk=status" /></AAT:BoxCol>
	<AAT:BoxCol align="C" cspan="7">
	<AAT:Label value="_ACTION" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="15"><hr></AAT:BoxCol></AAT:BoxRow>
<%
foreach my $d (@dconfs)
{
	my $name = $d->{name};
	my $desc = $d->{description};
	my $status = $d->{status};
	my $status_color = (($status =~ /Started/) 
		? "green" : (($status =~ /Paused/) ? "orange" : "red"));
%><AAT:BoxRow>
  <AAT:BoxCol><%
	if ($d->{reload_required})
	{
		%><AAT:Button name="reload" tooltip="_RELOAD"
    link="./devices.asp?device=$name&action=parse_reload" /><%
	}
%></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$name" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><%= $d->{address} %></AAT:BoxCol>
	<AAT:BoxCol><%= $d->{logtype} %></AAT:BoxCol>
  <AAT:BoxCol><%= $d->{type} %></AAT:BoxCol>
	<AAT:BoxCol><%= $d->{model} %></AAT:BoxCol>
  <AAT:BoxCol><i><AAT:Label value="$desc" /></i></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$status" color="$status_color" /></AAT:BoxCol>
	<%
	if ($status =~ /Stopped/)
	{
	%><AAT:BoxCol><AAT:Button name="pause" tooltip="_PAUSE"
    popup_link="./dialog.asp?id=parse_pause&arg1=$name" /></AAT:BoxCol>
		<AAT:BoxCol><AAT:Button name="start" tooltip="_START"
    popup_link="./dialog.asp?id=parse_start&arg1=$name" /></AAT:BoxCol><%
	}
	elsif ($status =~ /Paused/)
	{
	%><AAT:BoxCol><AAT:Button name="stop" tooltip="_STOP"
    popup_link="./dialog.asp?id=parse_stop&arg1=$name" /></AAT:BoxCol>
    <AAT:BoxCol><AAT:Button name="start" tooltip="_START"
    popup_link="./dialog.asp?id=parse_start&arg1=$name" /></AAT:BoxCol><%
	}
	elsif ($status =~ /Started/)
  {
  %><AAT:BoxCol><AAT:Button name="stop" tooltip="_STOP"
    popup_link="./dialog.asp?id=parse_stop&arg1=$name" /></AAT:BoxCol>
    <AAT:BoxCol><AAT:Button name="pause" tooltip="_PAUSE"
    popup_link="./dialog.asp?id=parse_pause&arg1=$name" /></AAT:BoxCol><%
  }
	%>
  <AAT:BoxCol><AAT:Button name="service" tooltip="_SERVICES"
		link="./device_services.asp?device=$name" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Button name="storage" tooltip="_STORAGES"     
		link="./device_storages.asp?device=$name" /></AAT:BoxCol> 
	<AAT:BoxCol><AAT:Button name="edit" tooltip="_EDIT"
    link="./device_edit.asp?device=$name" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Button name="report" tooltip="_DASHBOARD"
    link="./device_dashboard.asp?device=$name" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Button name="remove" tooltip="_REMOVE"
    popup_link="./dialog.asp?id=delete_device&arg1=$name&action=remove" />
	</AAT:BoxCol>
	</AAT:BoxRow><%
}
%>
</AAT:Box>
<%
if ($role !~ /ro/i)
{
	my @log_type = ("asynchronous", "syslog");
%>
<AAT:Form action="$url">
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_DEVICE_NAME" style="B"/></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_IP_ADDRESS" style="B"/></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_LOG_TYPE" style="B"/></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_DEVICE_TYPE" style="B"/></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_DEVICE_MODEL" style="B"/></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_DESCRIPTION" style="B"/></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="6"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Entry name="device" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="address" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Selector name="logtype" list=\@log_type selected="syslog"/></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Inc file="selector_device_type_dynamic" 
		selected="$arg{dtype}" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Inc file="octo_selector_device_model" 
		device_type="$arg{dtype}" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="description" /></AAT:BoxCol>
</AAT:BoxRow>	
<AAT:BoxRow><AAT:BoxCol cspan="6"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="C" cspan="6">
	<AAT:Form_Submit value="_NEW_DEVICE" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
<%
}
%>