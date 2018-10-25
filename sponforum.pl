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
my $url = "http://www.spiegel.de/forum/wirtschaft/freiheit-gefahr-ist-der-westen-noch-zu-retten-thread-817475-1.html";

# Zielpfad angeben (der Ordner wird ggf. neu angelegt)
my $path = "/Users/Simon/Korpora/SPON_Forum";

############################
# No changes below this line
############################

my $filename;
my $title;
my $date;
my $url_article;
my $teaser;
my $comment_user;
my $comment_title;
my $comment_p;

if ($url =~ /forum\/\w+\/(.*?)-thread-/) {
	$filename = "$path/$1.xml";
}
qx(mkdir -p $path);
open OUT, "> $filename";
my $html = qx(curl -s -L '$url');
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
	my $html = qx(curl -s -L '$url');
	my @comments = split (/class="postbit clearfix"/, $html);
	shift @comments;
	foreach (@comments) {
		if ($_ =~ /<a href="\/forum\/member-\d+.html"><b>(.*?)</) {
			$comment_user = $1;
		}
		if ($_ =~ /<div class="article-comment-title">\s+<a .+?>(.*?)</s) {
			$comment_title = decode_entities($1);
			$comment_title =~ s/\s+/ /g;
		}
		if ($_ =~ /<span class="postContent">(.+?)<\/span>/s) {
			$comment_p = decode_entities($1);
			$comment_p =~ s/<br \/>\s/ /g;
			$comment_p = clean_xml($comment_p);
		}
		print OUT "\t<comment>
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

sub clean_xml{
	my $path = $_[0];
	decode_entities($path);
	$path =~ s/&/\&amp;/g;
	$path =~ s/</\&lt;/g;
	$path =~ s/>/\&gt;/g;
	$path =~ s/[“”„«»]/"/g;
	$path =~ s/[’‘‚]/'/g;
	return($path);
}
