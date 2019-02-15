#!/usr/bin/perl -w

use strict;
use warnings;
use HTML::Entities;
use utf8;
use open ':std', ':encoding(utf8)';

###################################################################################
#                                                                                 #
#  Ein Script zum Scrapen von Kommentaren aus spiegel.de-Foren als xml-Datei      #
#  Autor: Simon Meier-Vieracker, www.fussballlinguistik.de.                       #
#  Berlin, Oktober 2018                                                           #
#                                                                                 #
###################################################################################

# URL angeben
my $url = "http://www.spiegel.de/forum/politik/spd-abkehr-von-hartz-iv-genossen-berauschen-sich-am-linksruck-thread-863514-1.html";

# Zielpfad angeben (der Ordner wird ggf. neu angelegt)
my $path = "/Pfad/zum/Ordner/SPON_Forum";

############################
# No changes below this line
############################

my $filename;
my $title;
my $date;
my $url_article;
my $teaser;
my $comment_user;
my $comment_url;
my $comment_date;
my $comment_nr;
my $comment_title;
my $comment_p;

if ($url =~ /forum\/\w+\/(.*?)-thread-/) {
	$filename = "$path/$1.xml";
}
qx(mkdir -p $path);
open OUT, "> $filename";
my $html = qx(curl -s -L $url);
if ($html =~ /<title>(.+?)</) {
	$title = $1;
}
if ($html =~ /href="(.+?)">zum Artikel<\/a>/) {
	$url_article = $1;
}
if ($html =~ /"datePublished":\s+"(.+?)T/) {
	$date = $1;
}
if ($html =~ /<p id="sysopText" class="clearfix postContent">\s+(.+?)<\/p>/) {
	$teaser = $1;
}
print OUT "<text>
	<title>$title</title>
	<url>$url</url>
	<url_article>$url_article</url_article>
	<date>$date</date>
	<teaser>$teaser</teaser>\n";
while (defined $url) {
	print "$url\n";
	my $html = qx(curl -s -L $url);
	my @comments = split (/class="postbit clearfix"/, $html);
	shift @comments;
	foreach (@comments) {
		if ($_ =~ /<a href="\/forum\/member-\d+.html"><b>(.*?)</) {
			$comment_user = $1;
			$comment_user = clean_xml($comment_user)
		}
		if ($_ =~ /<div class="article-comment-title">\s+<a class="\S+" href="(\S+)" \S+>(\d+)\.\s+(.*?)</s) {
			$comment_url = "http://www.spiegel.de" . $1;
			$comment_nr = $2;
			$comment_title = decode_entities($3);
			$comment_title =~ s/\s+/ /g;
			$comment_title = clean_xml($comment_title)
		}
		if ($_ =~ /<span class="postContent">(.+?)<\/span>/s) {
			$comment_p = decode_entities($1);
			$comment_p =~ s/<br \/>\s/ /g;
			$comment_p =~ s/<.+?>//g;
			$comment_p = clean_xml($comment_p);
		}
		if ($_ =~ /<span class="date-time">(.+?)</) {
			$comment_date = $1;
		}
		print OUT "\t<comment>
		<comment_nr>$comment_nr</comment_nr>
		<comment_url>$comment_url</comment_url>
		<comment_date>$comment_date</comment_date>
		<comment_user>$comment_user</comment_user>
		<comment_title>$comment_title</comment_title>
		<comment_p>$comment_p</comment_p>
	</comment>\n";
	}

	undef $url;
	if ($html =~ /<a class="page-next" href="(.+?)"/) {
		$url = "http://www.spiegel.de" . $1;
	}
}
print OUT "</text>\n";

sub clean_xml {
	my $path = $_[0];
	decode_entities($path);
	$path =~ s/&/\&amp;/g;
	$path =~ s/</\&lt;/g;
	$path =~ s/>/\&gt;/g;
	$path =~ s/[“”„«»]/"/g;
	$path =~ s/[’‘‚]/'/g;
	return($path);
}
