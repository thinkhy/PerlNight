######################################################################
# file:   gm.pl    
# brief:  Test tool for exacting image with GraphicsMagick 
# author: thinkhy 
# date:   11/01/07 
# changleLists:
#         11/01/10  Add the function of batch Test.
#                   Add ini file fore configuration.    
#
######################################################################

use File::Glob ':glob';

# http://search.cpan.org/~wadg/Config-IniFiles-2.38/IniFiles.pm
use Config::IniFiles;
#use Capture::Tiny 'capture'

use strict;

my $gmpath;

# 读入配置文件
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
    my $logfile = shift(@_);

    open LOG, ">>$logfile" or print "[WriteLog] Could not open $logfile: $!\n";
#or open LOG, ">$logfile" or print "[WriteLog] Could not open $logfile: $!\n";
    my $tt = getTime();
    my $t = $tt->{'year'}."\/".$tt->{'month'}."\/".$tt->{'day'}." $tt->{'hour'}:$tt->{'minute'}:$tt->{'second'} ";
    print LOG $t.": ".$str;
     
    close LOG;
}

sub getIni
{
    my $cnt = shift(@_);
    my $inifile = "test.ini";
    my $cfg = new Config::IniFiles( -file => $inifile,  
                                    -allowcontinue => 1,        
                                    -reloadwarn => 1,           
                                    -nocase  => 1,);           

    my $key = "test".$cnt;
    my $inputpath = $cfg->val($key, 'inputpath'); 

    my $filetype = $cfg->val($key, 'filetype'); 

    my $outputpath = $cfg->val($key, 'outputpath'); 

    return { 
             'inputpath' => $inputpath,
             'outputpath' => $outputpath,
             'filetype' => $filetype,
           };
}

sub TestCase
{
    my $cnt = shift(@_);
    my $para = getIni($cnt);

    return if $para->{outputpath} eq "";
    return if $para->{inputpath} eq "";
    return if $para->{filetype} eq "";

    my $logfile = $para->{outputpath}."\\log.txt"; 

    my $outputpath = $para->{outputpath};
    return if $outputpath eq "";

    my $filepattern = $para->{inputpath}."\\".$para->{filetype};

    print $filepattern."\n";
    my @files = bsd_glob $filepattern;

    my $file;

    my $fault = 0;

    my @output;  # 输出的文件集
#foreach $file (in $files)
    my $cnt = @files;
    if ($cnt == 0)
    {
        return;
    }


    print "共需转换".$cnt."个文件\n\n";
    my $ii = 0;
    foreach(@files)
    {
        my $src = $_;
        chomp($src);
        my($dirpath,$basename,$extname) = ($src =~ /^((?:.*[:\\\/])?)(.*)(\.[^.]*$)/s);  

        #my $outputFile = $dirpath.$basename.".jpg";
        my $outputFile = $outputpath."\\".$basename.".jpg";
        print $outputFile."\n";

        # TODO: 怎样判断文件转换成功
        my $cmd = "\"$gmpath\\gm\" convert "."\"".$src."\""." \"".$outputFile."\""; #." 2>&1";
        print ++$ii."\n";
        print $cmd."\n";

        push (@output, $outputFile);
        my $result = `$cmd`;
#or  {  writelog($src." 抽取失败\n", $logfile)};

    }

    sleep(3); # 等待IO做完 

    # 统计抽图失败的文件
    for (@output)
    {
        my $file = $_;

        if (!-e $file)
        {
           $fault++;
           writelog($file." 抽取失败\n", $logfile);
        }
    }

    my $report = "共转换文件".$cnt."个  "."转换成功:".($cnt-$fault)."个\n";
    writelog($report, $logfile);

    print $report;

}

BEGIN 
{
    my $inifile = "test.ini";
    my $cfg = new Config::IniFiles( -file => $inifile,  
                                    -allowcontinue => 1,        
                                    -reloadwarn => 1,           
                                    -nocase  => 1,);           

    my $casenum = $cfg->val("summary", 'casenum'); 
    $gmpath = $cfg->val("summary", 'gmpath'); 
    print $casenum;


    my $count = 1;
    while ($count <= $casenum) 
    {
        print "#########################\nTest Case ".$count."\n#########################\n";
        TestCase($count);
        $count++;
    }
    print "\n共完成".(--$count)."个测试用例\n";

    sleep(10);
}
