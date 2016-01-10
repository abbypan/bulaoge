#!/usr/bin/perl 

use strict;
use warnings;
use utf8;

use Encode::Locale;
use Encode;

use Web::Scraper;
use Novel::Robot;
use Data::Dumper;

$| = 1;
binmode( STDIN,  ":encoding(console_in)" );
binmode( STDOUT, ":encoding(console_out)" );
binmode( STDERR, ":encoding(console_out)" );


our $BASE_URL = 'http://bulaoge.net';

my ($writer, $book, $url, $year_s, $year_e) = @ARGV;
$writer=decode(locale=>$writer);
$book=decode(locale=>$book);

unless($url){
    print "example:
    perl bulaoge_year_title.pl 'black.f' '哦漏' 'http://bulaoge.net/archives.blg?dmn=73' 2010 2011
    \n";
    exit;
}

my $xs = Novel::Robot->new(site => 'txt', type => 'raw');

my @floor;
for my $i ( $year_s .. $year_e ) {
    my $u = "$url&t=y&d=$i";
    print "extract chapter url : $u\n";
    my $h = $xs->{browser}->request_url($u);
    
    my $r = scraper {
        process '//p//a' , 'chapter[]' => {
            title => 'TEXT',
            url => '@href'
        };
        result 'chapter';
    };
    my $chap_r = $r->scrape($h);
    my @chap = grep { $_->{title}=~/$book/ and $_->{url}=~/#Content$/ } @$chap_r;
    push @floor, @chap;
}

@floor = reverse @floor;
$xs->{parser}->update_url_list(\@floor, $BASE_URL);


for my $x ( @floor ){
    my $u = $x->{url};
    print "download chapter : $u\n";
    my $h = $xs->{browser}->request_url($u);
    my $r = scraper {
        process '//p[@class="blg-content"]' , 'content' => 'HTML';
        result 'content';
    };
    $x->{content} = $r->scrape($h);
}

my %book_data = (
    writer => $writer,
    book => $book,
    floor_list => \@floor, 
    url => $url, 
);


my $raw_f = "$writer-$book.raw";
$xs->{packer}->main(\%book_data, output => $raw_f);

#$xs = Novel::Robot->new(site => 'txt', type => 'html');
$xs->set_packer('html');
$xs->{packer}->main(\%book_data, output => "$writer-$book.html", with_toc => 1);

system(encode(locale=>qq[get_ebook.pl "$writer-$book.html" mobi]));
