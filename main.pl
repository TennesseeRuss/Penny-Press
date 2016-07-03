#!/usr/bin/perl
use Net::Twitter;
use Time::Local;
use IO::Socket::SSL;
use XML::RSS::Parser::Lite;
use HTTP::Request::Common qw(POST GET HEAD PUT);
use LWP::Simple;
use LWP::UserAgent;



$consumer_key = "";
$consumer_secret = "";
$access_token = "";
$access_token_secret = "";

$nt = Net::Twitter->new(
    traits              => [qw/API::RESTv1_1/],
    consumer_key        => $consumer_key,
    consumer_secret     => $consumer_secret,
    access_token        => $access_token,
    access_token_secret => $access_token_secret,
    ssl => 1
);

open(INPUT,"<./symbols.txt");
while ($line = <INPUT>) {
   chomp($line);
   push(@SYMBOLS,$line);
}
close(INPUT);

while(1) {
  GetPRFeedYahoo();
  GetPRFeedSeekingAlpha();
  sleep(900);
}


sub GetPRFeedYahoo() {

    my $title;
    my $link;
    my $pubDate;
    my $result;
    my $lcltime = time();
    my $dup_flag;

    for (my $s = 0; $s < scalar(@SYMBOLS); $s++) {


        print "parse RSS FEED for $SYMBOLS[$s]\n";
        my $xml = get("http://feeds.finance.yahoo.com/rss/2.0/headline?s=$SYMBOLS[$s]&region=US&lang=en-US");
        my $rp = new XML::RSS::Parser::Lite;
        $result = eval{ $rp->parse($xml) };
        print "RESULT FROM RSS FEED IS: $result\n";

        if ($result) {

          for (my $i = 0; $i < $rp->count(); $i++) {

               $dup_flag = 0;

               my $it = $rp->get($i);
               $title = $it->get('title');
               $link = $it->get('url');
               $orig_pubDate = $it->get('pubDate');
               $description = $it->get('description');


                $pubDate = $orig_pubDate;
                $pubDate =~ s/\,//;
                $pubDate =~ s/\:/ /g;
                $pubDate =~ s/ /\,/g;
                print "$dt\n";
                ($txt_day,$day,$txt_mon,$year,$hr,$min,$sec,$temp) = split /\,/,$pubDate;
                if (($day < 1) || ($day > 31)) {next;}
                if ($txt_day !~ m/[A-Z]/) {next;}
                $mon = ReturnMonth($txt_mon);
                $year = $year - 1900;
                $twttime = timegm($sec,$min,$hr,$day,$mon,$year);
                $twttime = $twttime - (5 * 3600);
                $diff = ($lcltime - $twttime)/3600;
                print "$link is $diff hours old...passing\n";

                open(NEWS,"<./news.txt");
                while ($newline = <NEWS>) {
                   chomp($newline);
                   if ($newline eq $link) {
                       $dup_flag = 1;
                       print "matched $newline to $link\n";
                   }
                }
                close(NEWS);


                if (($diff <= 6) && ($dup_flag == 0)) {
                     $sm_title = substr($title,0,110);
                     print "POSTING NEWS TO FACEBOOK - $sm_title $link\n";
                     my $message = "News on $SYMBOLS[$s]: $sm_title $link";
                     eval { $nt->update({ status => "$message" }) };
                     open(NEWS,">>./news.txt");
                     print NEWS "$link\n";
                     sleep(60);
                     close(NEWS);
                }

          }
        }

    }

}


sub GetPRFeedSeekingAlpha() {

    my $title;
    my $link;
    my $pubDate;
    my $result;
    my $lcltime = time();
    my $dup_flag;

    for (my $s = 0; $s < scalar(@SYMBOLS); $s++) {


        print "parse RSS FEED for $SYMBOLS[$s]\n";
        my $xml = get("http://seekingalpha.com/api/sa/combined/$SYMBOLS[$s].xml");
        my $rp = new XML::RSS::Parser::Lite;
        $result = eval{ $rp->parse($xml) };
        print "RESULT FROM RSS FEED IS: $result\n";

        if ($result) {

          for (my $i = 0; $i < $rp->count(); $i++) {

               $dup_flag = 0;

               my $it = $rp->get($i);
               $title = $it->get('title');
               $link = $it->get('url');
               $orig_pubDate = $it->get('pubDate');
               $description = $it->get('description');


                $pubDate = $orig_pubDate;
                $pubDate =~ s/\,//;
                $pubDate =~ s/\:/ /g;
                $pubDate =~ s/ /\,/g;
                print "$dt\n";
                ($txt_day,$day,$txt_mon,$year,$hr,$min,$sec,$temp) = split /\,/,$pubDate;
                if (($day < 1) || ($day > 31)) {next;}
                if ($txt_day !~ m/[A-Z]/) {next;}
                $mon = ReturnMonth($txt_mon);
                $year = $year - 1900;
                $twttime = timegm($sec,$min,$hr,$day,$mon,$year);
                $twttime = $twttime - (1 * 3600);
                $diff = ($lcltime - $twttime)/3600;
                print "$link is $diff hours old...passing\n";

                open(NEWS,"<./news.txt");
                while ($newline = <NEWS>) {
                   chomp($newline);
                   if ($newline eq $link) {
                       $dup_flag = 1;
                       print "matched $newline to $link\n";
                   }
                }
                close(NEWS);

                if (($diff <= 6) and ($dup_flag == 0)) {
                     print "POSTING NEWS TO FACEBOOK - $LINK\n $DESC\n $TITLE\n";
                     $sm_title = substr($title,0,110);
                     my $message = "Seeking Alpha Article on $SYMBOLS[$s]: $sm_title $link";
                     eval { $nt->update({ status => "$message" }) };
                     open(NEWS,">>./news.txt");
                     print NEWS "$link\n";
                     close(NEWS);
                     sleep(60);
                }

          }
        }

    }

}


sub ReturnMonth {
   my($month) = @_;

   my $i;
   my @a_month;

   @a_month = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
   for (my $i = 0; $i < scalar(@a_month); $i++) {
        if ($a_month[$i] =~ m/$month/) {
            return $i;
        }
   }
}
