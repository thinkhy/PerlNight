######################################################################

# file:   gm.pl    

# brief:  Test tool for exacting image with GraphicsMagick 

# author: thinkhy 

# date:   11/01/07 

######################################################################

use File::Glob ':glob';

use strict;

my @files = glob "D:\\抽图图片\\抽图出错图片189张\\*.eps";

my $logfile =   "D:\\抽图图片\\抽图出错图片189张\\extractImage.log";

sub getTime

{

    my $time = shift || time();

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);

    $year += 1900;

    $mon ++;

    $min  = '0'.$min  if length($min)  < 2;

    $sec  = '0'.$sec  if length($sec)  < 2;

    $mon  = '0'.$mon  if length($mon)  < 2;

    $mday = '0'.$mday if length($mday) < 2;

    $hour = '0'.$hour if length($hour) < 2;

    my $weekday = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat')[$wday];

    return { 'second' => $sec,

             'minute' => $min,

             'hour'   => $hour,

             'day'    => $mday,

             'month'  => $mon,

             'year'   => $year,

             'weekNo' => $wday,

             'wday'   => $weekday,

             'yday'   => $yday,

             'date'   => "$year-$mon-$mday"

          };

}

sub writelog

{

    my $str = shift(@_);

    open LOG, ">>$logfile" or die "Could not open my.log: $!";;

    my $tt = getTime();

    my $t = $tt->{'year'}."\/".$tt->{'month'}."\/".$tt->{'day'}." $tt->{'hour'}:$tt->{'minute'}:$tt->{'second'} ";

    print LOG $t.": ".$str;

    close LOG;

}

my $file;

my $fault = 0;

#foreach $file (in $files)

my $cnt = @files;

print "共转换".$cnt."个文件\n\n";

foreach(@files)

{

    my $src = $_;

    chomp($src);

    my($dirpath,$basename,$extname) = ($src =~ /^((?:.*[:\\\/])?)(.*)(\.[^.]*$)/s);  

    my $outputFile = $dirpath.$basename.".jpg";

    print $outputFile."\n";

    my $cmd = "gm convert "."\"".$src."\""." ".$outputFile;

    print $cmd;

    my $result = `$cmd` 

        or  { $fault++, writelog($src." 抽取失败\n")};

    print $result;

}

print "共转换文件".$cnt."个，转换成功:".($cnt-$fault)."个\n";

__END__
