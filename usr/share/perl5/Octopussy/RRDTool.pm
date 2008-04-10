=head1 NAME

Octopussy::RRDTool - Octopussy RRDTool module

=cut

package Octopussy::RRDTool;

use strict;
no strict 'refs';

my $MINUTE = 60;
my $HOURLY = 3600;
my $DAILY = 86400;
my $WEEKLY = 604800;
my $MONTHLY = 2592000;
my $YEARLY = 31536000;

my $RRDTOOL = "/usr/bin/rrdtool";
my $RRD_CREATE = "$RRDTOOL create";
my $RRD_GRAPH = "$RRDTOOL graph";
my $RRD_INFO = "$RRDTOOL info";
my $RRD_UPDATE = "$RRDTOOL update";
my $NICE_RRDGRAPH = "nice -n 15";

my $RRD_DIR = "/var/lib/octopussy/rrd";
my $RRD_PNG_DIR = "/usr/share/octopussy/rrd";
my $RRD_SYSLOG = "$RRD_DIR/syslog.rrd";
my $RRD_SYSLOG_DTYPE = "$RRD_DIR/syslog_dtype.rrd";

my $RRA = "RRA:AVERAGE:0.5:1:60 RRA:AVERAGE:0.5:5:288 RRA:AVERAGE:0.5:30:336"
	. " RRA:AVERAGE:0.5:60:720 RRA:AVERAGE:0.5:240:2190";

my $GRAPH_WIDTH = 400;
my $GRAPH_HEIGHT = 180;

my @colors = ( 
	"#FF0000", "#00FF00", "#0000FF", "#FFFF00", "#FF00FF", "#00FFFF",
	"#DD0000", "#00DD00", "#0000DD", "#DDDD00", "#DD00DD", "#00DDDD",
	"#AA0000", "#00AA00", "#0000AA", "#AAAA00", "#AA00AA", "#00AAAA",
	"#660000", "#006600", "#000066", "#666600", "#660066", "#006666",
	"#330000", "#003300", "#000033", "#333300", "#330033", "#003333");

=head1 FUNCTIONS

=head2 DS_Count($file)

Counts number of Data Sources in RRD file

=cut

sub DS_Count($)
{
	my $file = shift;

	my @lines = `$RRD_INFO "$file" | grep ds | grep ".type = "`;
	
	return ($#lines+1);
}

=head2 Graph_Legend($cdef)

Set RRD Graph Legend (Min, Avg, Max) for Command Line

=cut

sub Graph_Legend($)
{
	my $cdef = shift;
	
	my $str = "GPRINT:$cdef:MIN:\"Min\\:\%6.0lf\" ";
	$str .= "GPRINT:$cdef:AVERAGE:\"Average\\:\%6.0lf\" "; 
	$str .= "GPRINT:$cdef:MAX:\"Max\\:\%6.0lf\\n\"";
	
	return ("$str");
}

=head2 Graph_Line($cdef, $type, $color, $title)

=cut

sub Graph_Line($$$$)
{
	my ($cdef, $type, $color, $title) = @_;

	$title =~ s/://;
	$title .= " "x(24 - length($title));
	return ("$type:$cdef$color:\"$title\""); 
}

=head2 Graph_Parameters($file, $start, $end, $title, $w, $h, $vlabel)

Set RRD Graph Parameters for Command Line

=cut

sub Graph_Parameters($$$$$$$)
{
	my ($file, $start, $end, $title, $w, $h, $vlabel) = @_;

	my $cmd = "$RRD_GRAPH \"$file\" --start=$start --end=$end ";
	$cmd .= "--title=\"$title\" --width=$w --height=$h --alt-autoscale-max ";
	$cmd .= "--vertical-label=\"$vlabel\" ";

	return ($cmd);
}

=head2 Syslog_By_DeviceType_Init()

=cut

sub Syslog_By_DeviceType_Init()
{
	my @dtypes = Octopussy::Device::Types();
	my $ds_count = undef;
	$ds_count = DS_Count($RRD_SYSLOG_DTYPE)	if (-f "$RRD_SYSLOG_DTYPE");

	if ((! -f "$RRD_SYSLOG_DTYPE") || ($ds_count != ($#dtypes+1)))
  {
		Octopussy::Create_Directory($RRD_DIR);
		my $cmd = "$RRD_CREATE \"$RRD_SYSLOG_DTYPE\" --step $MINUTE ";
		foreach my $dt (@dtypes)
		{ 
			$dt =~ s/[-\s+]/_/g;
			$cmd .= "DS:$dt:GAUGE:120:0:U ";	
		}
		$cmd .= $RRA;
		`$cmd`;
  }	
}

=head2 Syslog_By_DeviceType_Update($values)

=cut

sub Syslog_By_DeviceType_Update($)
{
	my $values = shift;
	my $value_str = join(":", AAT::ARRAY($values));

  `$RRD_UPDATE "$RRD_SYSLOG_DTYPE" N:$value_str`
		if (-f "$RRD_SYSLOG_DTYPE");
}

=head2 Syslog_By_DeviceType_Graph($file, $title, $length)

=cut

sub Syslog_By_DeviceType_Graph($$$)
{
  my ($file, $title, $length) = @_;

	if (-f "$RRD_SYSLOG_DTYPE")
	{
		my %type = Octopussy::Device::Type_Configurations();
		my $cmd = "$NICE_RRDGRAPH " . Graph_Parameters("$RRD_PNG_DIR/${file}.png",
			"-$length", "-120", $title, $GRAPH_WIDTH, $GRAPH_HEIGHT, 
			"Logs by Device Type");

		my $first = 1;
		foreach my $dt (Octopussy::Device::Types())
		{
			my $color = $type{$dt}{color} || "#909090";
			my $type_name = $dt;
			my $type = ($first ? "AREA" : "STACK");
			$dt =~ s/[-\s+]/_/g;
			$cmd .= "DEF:$dt=\"$RRD_SYSLOG_DTYPE\":$dt:AVERAGE CDEF:cdef$dt=$dt ";
			$cmd .= Graph_Line($dt, $type, $color, "Logs $type_name ") 
				. " " . Graph_Legend($dt) . " ";
			$first = 0;
		}
		`$cmd`;
	}
}

=head2 Syslog_By_DeviceType_Hourly_Graph()

=cut

sub Syslog_By_DeviceType_Hourly_Graph()
{
	Syslog_By_DeviceType_Graph("syslog_dtype_hourly", "Hourly Stats", $HOURLY);	
}

=head2 Syslog_By_DeviceType_Daily_Graph()

=cut

sub Syslog_By_DeviceType_Daily_Graph()
{
  Syslog_By_DeviceType_Graph("syslog_dtype_daily", "Daily Stats", $DAILY);
}

=head2 Syslog_By_DeviceType_Weekly_Graph()

=cut

sub Syslog_By_DeviceType_Weekly_Graph()
{
  Syslog_By_DeviceType_Graph("syslog_dtype_weekly", "Weekly Stats", $WEEKLY);
}

=head2 Syslog_By_DeviceType_Monthly_Graph()

=cut

sub Syslog_By_DeviceType_Monthly_Graph()
{
	Syslog_By_DeviceType_Graph("syslog_dtype_monthly", "Monthly Stats", $MONTHLY);
}

=head2 Syslog_By_DeviceType_Yearly_Graph()

=cut

sub Syslog_By_DeviceType_Yearly_Graph()
{
  Syslog_By_DeviceType_Graph("syslog_dtype_yearly", "Yearly Stats", $YEARLY);
}



=head2 Syslog_By_Device_Service_Taxonomy_Init($device, $service)

=cut

sub Syslog_By_Device_Service_Taxonomy_Init($$)
{
	my ($device, $service) = @_;

	my $file = "$RRD_DIR/$device/taxonomy_$service.rrd";
  if (! -f $file)
  {
		Octopussy::Create_Directory("$RRD_DIR/$device");
    my $cmd = "$RRD_CREATE \"$file\" --step $MINUTE ";
		my @list = Octopussy::Taxonomy::List();
    foreach my $taxo (sort @list)
		{
			$taxo =~ s/\./_/g;
			$cmd .= "DS:$taxo:GAUGE:120:0:U "; 
		}
    $cmd .= $RRA;
    `$cmd`;
  }
}

=head2 Syslog_By_Device_Service_Taxonomy_Update($seconds, $device, $service, 
$values)

=cut

sub Syslog_By_Device_Service_Taxonomy_Update($$$$)
{
  my ($seconds, $device, $service, $values) = @_;
	my $file = "$RRD_DIR/$device/taxonomy_$service.rrd";
	my $value_str = join(":", AAT::ARRAY($values));

	`$RRD_UPDATE "$file" $seconds:$value_str 2> /dev/null`;
}

=head2 Syslog_By_Device_Service_Taxonomy_Graph($device, $service, $file, 
$title, $length)

=cut

sub Syslog_By_Device_Service_Taxonomy_Graph($$$$$)
{
  my ($device, $service, $file, $title, $length) = @_;
  my $cmd = "$NICE_RRDGRAPH " . Graph_Parameters("$RRD_PNG_DIR/${file}.png",
		"-$length", "-120", $title, $GRAPH_HEIGHT, $GRAPH_WIDTH, 
		"Logs Taxonomy for $service");

	my %taxo_color = Octopussy::Taxonomy::Colors();	
  my $first = 1;
	my @list = Octopussy::Taxonomy::List();
  foreach my $t (sort @list)
  {
		my $color = $taxo_color{$t} || "#909090";
    my $type_name = $t;
		$t =~ s/\./_/g;
    my $type = ($first ? "AREA" : "STACK");
    $cmd .= "DEF:$t=\"$RRD_DIR/$device/taxonomy_$service.rrd\":$t:AVERAGE"
			. " CDEF:cdef$t=$t ";
    $cmd .= Graph_Line($t, $type, $color, "Logs $type_name")
      . " " . Graph_Legend($t) . " ";
    $first = 0;
  }
  `$cmd`;
}

=head2 Syslog_By_Device_Service_Taxonomy_Hourly_Graph($device, $service)

=cut

sub Syslog_By_Device_Service_Taxonomy_Hourly_Graph($$)
{
	my ($device, $service) = @_;
	
	Syslog_By_Device_Service_Taxonomy_Graph($device, $service, 
		"taxonomy_${device}-${service}_hourly", "Hourly Stats", $HOURLY);
}

=head2 Syslog_By_Device_Service_Taxonomy_Daily_Graph($device, $service)

=cut

sub Syslog_By_Device_Service_Taxonomy_Daily_Graph($$)
{
  my ($device, $service) = @_;

  Syslog_By_Device_Service_Taxonomy_Graph($device, $service,
    "taxonomy_${device}-${service}_daily", "Daily Stats", $DAILY);
}

=head2 Syslog_By_Device_Taxonomy_Graph($device)

=cut

sub Syslog_By_Device_Taxonomy_Graph($$$$)
{
	my ($device, $file, $title, $length) = @_;

	my $cmd = Graph_Parameters("$RRD_PNG_DIR/${file}.png", "-$length", "-120",
		$title, $GRAPH_WIDTH, $GRAPH_HEIGHT, "Logs Taxonomy for $device");
	my @services = Octopussy::Device::Services($device);
	my %taxo_color = Octopussy::Taxonomy::Colors();
  my @list = Octopussy::Taxonomy::List();
	my ($def, $cdef, $legend) = ("", "", "");
	my $first = 1;
  foreach my $t (sort @list)
  {
		my $i = 0;
		my $type_name = $t;
		#$cdef .= " CDEF:$t=$t" . chr(65+$i) . ",UN,0,$t" . chr(65+$i) . ",IF,";
    my $color = $taxo_color{$t} || "#909090";
		$t =~ s/\./_/g;
    my $type = ($first ? "AREA" : "STACK");
		foreach my $s (@services)
		{
			if (-f "$RRD_DIR/$device/taxonomy_$s.rrd")
			{
    		$def .= "DEF:$t" . chr(65+$i) 
					. "=\"$RRD_DIR/$device/taxonomy_$s.rrd\":$t:AVERAGE ";
				$cdef .= ($i == 0 ? " CDEF:$t=" : "") . "$t" . chr(65+$i) 
					. ",UN,0,$t" . chr(65+$i) . ",IF," . ($i > 0 ? "+," : "");
					#. ",IF,+,"	if ($i > 0);
				$i++;
			}
		}
		$cdef =~ s/,$//;
		$legend .= Graph_Line($t, $type, $color, "Logs $type_name")
			. " " . Graph_Legend($t) . " ";
		$first = 0;
	}
	$cmd .= " $def $cdef $legend";
	`$cmd`	if (($cdef ne "") && ($def ne ""));
}

=head2 Syslog_By_Device_Taxonomy_Hourly_Graph($device)

=cut

sub Syslog_By_Device_Taxonomy_Hourly_Graph($)
{
	my $device = shift;
	
	Octopussy::RRDTool::Syslog_By_Device_Taxonomy_Graph($device,
 		"taxonomy_${device}_hourly", "Hourly Stats", $HOURLY);
}

=head2 Syslog_By_Device_Taxonomy_Daily_Graph($device)

=cut

sub Syslog_By_Device_Taxonomy_Daily_Graph($)
{
  my $device = shift;

  Octopussy::RRDTool::Syslog_By_Device_Taxonomy_Graph($device,
  	"taxonomy_${device}_daily", "Daily Stats", $DAILY);
}

=head2 Syslog_By_Device_Taxonomy_Weekly_Graph($device)

=cut

sub Syslog_By_Device_Taxonomy_Weekly_Graph($)
{
  my $device = shift;

  Octopussy::RRDTool::Syslog_By_Device_Taxonomy_Graph($device,
  	"taxonomy_${device}_weekly", "Weekly Stats", $WEEKLY);
}

=head2 Syslog_By_Device_Taxonomy_Monthly_Graph($device)

=cut

sub Syslog_By_Device_Taxonomy_Monthly_Graph($)
{
  my $device = shift;

  Octopussy::RRDTool::Syslog_By_Device_Taxonomy_Graph($device,
  	"taxonomy_${device}_monthly", "Monthly Stats", $MONTHLY);
}

=head2 Syslog_By_Device_Taxonomy_Yearly_Graph($device)

=cut

sub Syslog_By_Device_Taxonomy_Yearly_Graph($)
{
  my $device = shift;

  Octopussy::RRDTool::Syslog_By_Device_Taxonomy_Graph($device,
    "taxonomy_${device}_yearly", "Yearly Stats", $YEARLY);
}


=head2 Report_Graph($rconf, $begin, $end, $output, $data, $stats, $lang)

=cut

sub Report_Graph($$$$$$$)
{
	my ($rconf, $begin, $end, $output, $data, $stats, $lang) = @_;
	my ($dsv, $ds1, $ds2, $ds3) = ($rconf->{datasources_value},
		$rconf->{datasource1}, $rconf->{datasource2}, $rconf->{datasource3});
	$dsv = $2 if ($dsv =~ /^(\S+::\S+)\((\S+)\)/);
	$ds1 = $2	if ($ds1 =~ /^(\S+::\S+)\((\S+)\)/);
	$ds2 = $2 if ($ds2 =~ /^(\S+::\S+)\((\S+)\)/);
	$ds3 = $2 if ($ds3 =~ /^(\S+::\S+)\((\S+)\)/);

	my $tl = $rconf->{timeline};
	my $title = $rconf->{graph_title} || "";
	my $width = $rconf->{graph_width} || $GRAPH_WIDTH;	
	my $height = $rconf->{graph_height} || $GRAPH_HEIGHT;

	my %ds = ();
	my %dataline = ();
	foreach my $l (AAT::ARRAY($data))
	{
		my $key = $l->{$ds1}  
			. (AAT::NOT_NULL($l->{$ds2}) ? " / $l->{$ds2}" : "")
			. (AAT::NOT_NULL($l->{$ds3}) ? " / $l->{$ds3}" : "");
		if (AAT::NOT_NULL($key))
		{
			$ds{$key} = 1	;
			$dataline{$l->{$tl}}{$key} = $l->{$dsv};
		}
	}

	my $diff = $end-$begin;
	my $rrd_file = $output;
	$rrd_file =~ s/\.png/\.rrd/;
	my $start = `date +%s -d '$1 $2:$3'`	if ($begin =~ /(\d{8})(\d\d)(\d\d)/);
	my $finish = `date +%s -d '$1 $2:$3'`	if ($end =~ /(\d{8})(\d\d)(\d\d)/);
	chomp($start);
	chomp($finish);
	$start -= 60;
	
	my $cmd = "$RRD_CREATE \"$rrd_file\" --start $start --step " 
		. ($MINUTE*$rconf->{rrd_step}) . " ";
	my $i = 1;
	foreach my $k (sort keys %ds)
	{
		$cmd .= "DS:ds$i:GAUGE:120:0:U ";
		$ds{$k} = $i;
		$i++;
	}
	$cmd .= "RRA:AVERAGE:0.5:1:$diff";
	`$cmd`;

	foreach my $ts (sort keys %dataline)
	{
		my $update = "$ts:";
		foreach my $d (sort keys %ds)
			{ $update .= ($dataline{$ts}{$d} || "0") . ":"; }
		$update =~ s/:$//;
		`$RRD_UPDATE "$rrd_file" $update`;
	}

	$cmd = Graph_Parameters($output, $start, $finish, $title, $width, $height, $rconf->{graph_ylabel});

	my $watermark = AAT::Translation::Get($lang, "_MSG_REPORT_GENERATED_BY") 
		. " v" . Octopussy::Version() . " - "; 
  $watermark .= sprintf(AAT::Translation::Get($lang, "_MSG_REPORT_DATA_SOURCE"),
    $stats->{nb_files}, $stats->{nb_lines}, 
		int($stats->{seconds} / 60), $stats->{seconds} % 60);
	$cmd .= "--watermark \"$watermark\" ";
 	$i = 1;	
	foreach my $k (sort keys %ds)
  {
  	my $color = $colors[$i-1];
  	my $rtype = (($rconf->{graph_type} =~ /rrd_line/) ? "LINE" 
			: (($i == 1) ? "AREA" : "STACK"));
    $cmd .= "DEF:def$i=\"$rrd_file\":ds$i:AVERAGE CDEF:cdef$i=def$i ";
   	$cmd .= Graph_Line("cdef$i", $rtype, $color, $k)
    	. " " . Graph_Legend("cdef$i") . " ";
    $i++;
  }
	`$cmd`;
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
